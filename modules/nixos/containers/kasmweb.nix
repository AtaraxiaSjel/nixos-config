{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool;

  cfg = config.ataraxia.containers.kasmweb;
  dataPath = "${config.persist.persistRoot}/containers/kasmweb/data";
  dockerPath = "${config.persist.persistRoot}/containers/kasmweb/docker";
  nginx = config.ataraxia.services.nginx;
  domain = "kasm.ataraxiadev.com";
in
{
  options.ataraxia.containers.kasmweb = {
    enable = mkEnableOption "Enable kasmweb nixos-container";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    containers.kasmweb = {
      autoStart = true;
      ephemeral = true;
      additionalCapabilities = [
        "CAP_SYS_ADMIN"
        "CAP_NET_ADMIN"
        "CAP_BPF"
      ];
      extraFlags = [
        "--system-call-filter=bpf"
        "--system-call-filter=@keyring"
      ];
      bindMounts = mkIf config.persist.enable {
        "/var/lib/kasmweb" = {
          hostPath = dataPath;
          isReadOnly = false;
        };
        "/var/lib/docker" = {
          hostPath = dockerPath;
          isReadOnly = false;
        };
      };
      hostBridge = "br66";
      privateNetwork = true;
      config =
        { ... }:
        {
          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "kasmweb"
            ];
          systemd.network.networks."10-eth0" = {
            # matchConfig.Name = "eth0";
            matchConfig.Name = "eth0";
            linkConfig.MACAddress = "02:ed:09:e4:c3:c3";
            networkConfig.DHCP = "ipv4";
          };
          virtualisation.docker.daemon.settings = {
            dns = [
              "9.9.9.11"
              "1.1.1.1"
            ];
          };
          services.kasmweb = {
            enable = true;
            datastorePath = "/var/lib/kasmweb";
            networkSubnet = "172.20.0.0/16";
          };
          networking = {
            enableIPv6 = false;
            nftables.enable = true;
            useNetworkd = true;
            # hostName = "tinyproxy-node";
            useHostResolvConf = false;
            firewall = {
              enable = true;
              allowedTCPPorts = [
                443
                3389
              ];
            };
          };
          system.stateVersion = "26.05";
        };
    };

    systemd.tmpfiles.rules = mkIf config.persist.enable [
      "d ${dataPath} 0755 root root -"
      "d ${dockerPath} 0700 root root -"
    ];

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          # TODO: get ip by local domain
          proxyPass = "https://10.10.66.11:443";
          proxyWebsockets = true;
          recommendedProxySettings = false;
          extraConfig = ''
            proxy_ssl_verify off;
            proxy_ssl_server_name on;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;
            client_max_body_size 250M;
          '';
        };
      };
    };
  };
}
