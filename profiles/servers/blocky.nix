{ config, pkgs, lib, ... }: {

  containers.blocky = {
    # extraFlags = [ "-U" ];
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.0.5/24";
    tmpfs = [ "/" ];
    config = { config, pkgs, ... }: {
      networking = {
        defaultGateway = "192.168.0.1";
        hostName = "blocky-node";
        nameservers = [ "127.0.0.1" ];
        enableIPv6 = false;
        useHostResolvConf = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [
            953
            # config.services.prometheus.port
            config.services.blocky.settings.port
            # config.services.blocky.settings.httpPort
            # config.services.grafana.settings.server.http_port
          ];
          allowedUDPPorts = [ 53 ];
          rejectPackets = false;
        };
      };
      services.blocky = {
        enable = true;
        settings = {
          upstream.default = [ "127.0.0.1:953" ];
          upstreamTimeout = "10s";
          blocking = {
            blackLists.ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
            clientGroupsBlock.default = [ "ads" ];
          };
          port = 53;
          httpPort = 4000;
          # httpPort = 8080;
          # httpsPort = 8443;
          # customDNS = {
          #   # customTTL = "1h";
          #   # filterUnmappedTypes = "true";
          #   mapping = {
          #     "code.ataraxiadev.com" = "192.168.0.10";
          #   };
          # };
          queryLog = {
            type = "console";
          };
          prometheus.enable = true;
        };
      };
      services.prometheus = {
        # enable = true;
        port = 9090;
        listenAddress = "0.0.0.0";
        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };
        scrapeConfigs = [{
          job_name = "blocky";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.blocky.settings.httpPort}" ];
          }];
        }];
      };
      services.grafana = {
        # enable = true;
        settings = {
          analytics.reporting_enabled = false;
          server = {
            http_port = 3000;
            http_addr = "0.0.0.0";
            enable_gzip = true;
          };
          security = {
            admin_user = "admin";
            admin_password = "admin";
            # admin_password = "$__file(/var/secrets/grafana)";
          };
        };
        provision.enable = true;
        provision.datasources.settings = {
          apiVersion = 1;
          datasources = [{
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            orgId = 1;
            url = "127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
            jsonData = {
              graphiteVersion = "1.1";
              tlsAuth = false;
              tlsAuthWithCACert = false;
            };
            version = 1;
            editable = true;
          }];
          deleteDatasources = [{
            name = "Prometheus";
            orgId = 1;
          }];
        };
      };
      services.dnscrypt-proxy2 = {
        enable = true;
        settings = {
          listen_addresses = [ "0.0.0.0:953" ];
          ipv6_servers = false;
          doh_servers = false;
          require_dnssec = true;
          require_nolog = true;
          require_nofilter = true;
          block_ipv6 = true;
          bootstrap_resolvers = [ "9.9.9.9:53" "9.9.9.11:53" ];
          sources = {
            public-resolvers = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
              ];
              cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            };
          };
        };
      };
      system.stateVersion = "23.05";
    };
  };
}