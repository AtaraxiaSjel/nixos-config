{ config, lib, pkgs, ... }:
let
  inherit (import ../hardware/networks.nix) interfaces;
  wg = interfaces.wireguard0;
  wgIfname = wg.ifname;
  brIfname = interfaces.main'.bridgeName;
  tailscaleIfname = config.services.tailscale.interfaceName;
in {
  networking.extraHosts = ''
    192.0.46.9 www.internic.net
  '';
  # For debugging purposes
  environment.systemPackages = with pkgs; [ tcpdump dnsutils ];
  services.resolved.extraConfig = ''
    DNSStubListener=off
  '';
  systemd.network.networks."20-${brIfname}".networkConfig.DNS = lib.mkForce "127.0.0.1";
  systemd.network.networks."90-${wgIfname}".networkConfig.DNS = lib.mkForce "127.0.0.1";

  networking.firewall.interfaces = let
    ports = {
      allowedTCPPorts = [
        config.services.blocky.settings.ports.dns
        # config.services.grafana.settings.server.http_port
      ];
      allowedUDPPorts = [
        config.services.blocky.settings.ports.dns
      ];
    };
  in {
    ${wgIfname} = ports;
    ${tailscaleIfname} = ports;
  };

  # TODO: DoH (https://unbound.docs.nlnetlabs.nl/en/latest/topics/privacy/dns-over-https.html)
  services.unbound = {
    enable = true;
    package = pkgs.unbound-full;
    settings = {
      server = {
        root-hints = "${config.services.unbound.stateDir}/root.hints";
        port = "553";
        interface = [
          "127.0.0.1"
          "::1"
        ];
        access-control = [
          "0.0.0.0/0 refuse"
          "127.0.0.0/8 allow"
          "::0/0 refuse"
          "::1 allow"
        ];
        private-address = [
          "127.0.0.0/8"
          "::1"
        ];
	      hide-version = "yes";
        aggressive-nsec = "yes";
        cache-max-ttl = "86400";
        cache-min-ttl = "600";
        deny-any = "yes";
        do-ip4 = "yes";
        do-ip6 = "yes";
        do-tcp = "yes";
        do-udp = "yes";
        harden-algo-downgrade = "yes";
        harden-dnssec-stripped = "yes";
        harden-glue = "yes";
        harden-large-queries = "yes";
        harden-referral-path = "yes";
        harden-short-bufsize = "yes";
        hide-identity = "yes";
        minimal-responses = "yes";
        msg-cache-size = "128m";
        neg-cache-size = "4m";
        prefer-ip6 = "no";
        prefetch = "yes";
        prefetch-key = "yes";
        qname-minimisation = "yes";
        rrset-cache-size = "256m";
        rrset-roundrobin = "yes";
        serve-expired = "yes";
        so-rcvbuf = "4m";
        so-reuseport = "yes";
        so-sndbuf = "4m";
        unwanted-reply-threshold = "100000";
        use-caps-for-id = "yes";
      };
      cachedb = {
        backend = "redis";
        redis-server-host = "127.0.0.1";
        redis-server-port = toString config.services.redis.servers.unbound.port;
        redis-timeout = "300";
        redis-expire-records = "no";
      };
    };
  };
  services.redis.vmOverCommit = true;
  services.redis.servers.unbound = {
    enable = true;
    port = 7379;
    databases = 1;
    save = [ [ 3600 1 ] [ 1800 10 ] [ 600 100 ] ];
    settings = {
      maxmemory = "16mb";
      protected-mode = true;
      rdbchecksum = false;
      stop-writes-on-bgsave-error = false;
      tcp-keepalive = 300;
      timeout = 0;
    };
  };
  # TODO: maybe set internic ip address to hosts?
  systemd.services.root-hints = {
    script = ''
      ${pkgs.wget}/bin/wget -O ${config.services.unbound.stateDir}/root.hints https://www.internic.net/domain/named.root
    '';
    serviceConfig.Type = "oneshot";
    startAt = "weekly";
  };
  # systemd.services.unbound = {
  #   after = [ "root-hints.service" ];
  # };
  # Blocky + prometheus + grafana
  services.blocky = {
    enable = true;
    settings = {
      upstream.default = [ "127.0.0.1:553" "[::1]:553" ];
      upstreamTimeout = "10s";
      bootstrapDns = [{
        upstream = "https://dns.quad9.net/dns-query";
        ips = [ "9.9.9.9" "149.112.112.112" ];
      }];
      blocking = {
        blackLists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://github.com/RPiList/specials/raw/master/Blocklisten/malware"
          ];
          telemetry = [
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            "https://github.com/RPiList/specials/raw/master/Blocklisten/MS-Office-Telemetry"
            "https://github.com/RPiList/specials/raw/master/Blocklisten/Win10Telemetry"
            ../../../misc/telemetry.hosts
          ];
        };
        clientGroupsBlock.default = [ "ads" "telemetry" ];
      };
      # disable caching (use unbound)
      caching = {
        minTime = -1;
        maxTime = -1;
        cacheTimeNegative = -1;
        prefetching = false;
      };
      ports = {
        dns = 53;
        http = "127.0.0.1:4000";
      };
      prometheus.enable = true;
      queryLog = {
        type = "console";
      };
    };
  };
  # services.prometheus = {
  #   enable = true;
  #   listenAddress = "127.0.0.1";
  #   globalConfig.scrape_interval = "15s";
  #   globalConfig.evaluation_interval = "15s";
  #   scrapeConfigs = [{
  #     job_name = "blocky";
  #     static_configs = [{
  #       targets = [ config.services.blocky.settings.ports.http ];
  #     }];
  #   }];
  # };
  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     analytics.reporting_enabled = false;
  #     server = {
  #       enable_gzip = true;
  #       domain = "localhost";
  #       http_addr = "0.0.0.0";
  #       http_port = 3000;
  #     };
  #     # Grafana can be accessed only through wireguard, so it's secure enough
  #     security = {
  #       admin_user = "admin";
  #       admin_password = "admin";
  #     };
  #     panels.disable_sanitize_html = true;
  #   };
  #   provision = {
  #     enable = true;
  #     datasources.settings = {
  #       datasources = [{
  #         name = "Prometheus";
  #         type = "prometheus";
  #         access = "proxy";
  #         orgId = 1;
  #         uid = "Y4SSG429DWCGDQ3R";
  #         url = "http://127.0.0.1:${toString config.services.prometheus.port}";
  #         isDefault = true;
  #         jsonData = {
  #           graphiteVersion = "1.1";
  #           tlsAuth = false;
  #           tlsAuthWithCACert = false;
  #         };
  #         version = 1;
  #         editable = true;
  #       }];
  #     };
  #     dashboards = {
  #       settings = {
  #         providers = [{
  #           name = "My Dashboards";
  #           options.path = "/etc/grafana-dashboards";
  #         }];
  #       };
  #     };
  #   };
  # };
  # environment.etc = {
  #   "grafana-dashboards/blocky_rev3.json" = {
  #     source = ../../../misc/grafana_blocky_rev3.json;
  #     group = "grafana";
  #     user = "grafana";
  #   };
  # };

  persist.state.directories = [
    "/var/lib/grafana"
    "/var/lib/prometheus2"
    "/var/lib/redis-unbound"
    "/var/lib/unbound"
  ];
}