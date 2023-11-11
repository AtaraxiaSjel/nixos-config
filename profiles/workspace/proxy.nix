{ config, pkgs, lib, ... }: {
  secrets."xray-config.json".permissions = "444";
  secrets.tor-config = {};

  services.xray = {
    enable = true;
    settingsFile = config.secrets."xray-config.json".decrypted;
  };

  containers.tor = {
    autoStart = false;
    ephemeral = true;
    # extraFlags = [ "-U" ]; # unprivileged
    hostAddress = "192.168.1.10";
    localAddress = "192.168.1.11";
    privateNetwork = true;
    tmpfs = [ "/" ];
    bindMounts."/var/secrets" = {
      hostPath = "/var/secrets";
      isReadOnly = true;
    };
    config = { config, pkgs, ... }: {
      services.tor.enable = true;
      systemd.services.tor-config = {
        script = ''
          cp /var/secrets/tor-config /var/lib/tor/tor-config
          chown tor /var/lib/tor/tor-config
          chmod 600 /var/lib/tor/tor-config
          sed -i 's#obfs4proxy-path#${pkgs.obfs4}/bin/obfs4proxy#' /var/lib/tor/tor-config
        '';
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
      };
      systemd.services.tor = {
        after = [ "tor-config.service" ];
        serviceConfig.ExecStart = lib.mkForce "${config.services.tor.package}/bin/tor -f /var/lib/tor/tor-config";
      };
      networking = {
        enableIPv6 = false;
        nameservers = [ "127.0.0.1" ];
        firewall = {
          enable = true;
          allowedTCPPorts = [ 9050 ];
          rejectPackets = false;
        };
        useHostResolvConf = false;
      };
      services.dnscrypt-proxy2 = {
        enable = true;
        settings = {
          ipv6_servers = false;
          doh_servers = false;
          require_dnssec = true;
          require_nolog = true;
          require_nofilter = true;
          block_ipv6 = true;
          bootstrap_resolvers = [ "9.9.9.11:53" "9.9.9.9:53" ];
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
          force_tcp = true;
          proxy = "socks5://127.0.0.1:9050";
        };
      };
      system.stateVersion = "22.11";
    };
  };

  networking.nat.internalInterfaces = [ "ve-tor" ];
}
