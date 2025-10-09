{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types)
    bool
    enum
    listOf
    str
    submodule
    ;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.headscale;
  nginx = config.ataraxia.services.nginx;
  domain = "wg.ataraxiadev.com";

  dnsEntry = submodule {
    options = {
      name = mkOption {
        type = str;
      };
      type = mkOption {
        type = enum [
          "A"
          "AAAA"
        ];
      };
      value = mkOption {
        type = str;
      };
    };
  };
in
{
  options.ataraxia.services.headscale = {
    enable = mkEnableOption "Enable headscale service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
    extraDns = mkOption {
      type = listOf dnsEntry;
      description = ''
        Extra dns records for headscale.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = ports.headscale.int;
      settings = {
        server_url = "https://${domain}";
        ip_prefixes = [
          "fd7a:115c:a1e0::/64"
          "100.64.0.0/16"
        ];
        dns = {
          override_local_dns = true;
          base_domain = "tailnet.ataraxiadev.com";
          nameservers.global = [ "127.0.0.1" ];
          extra_records = cfg.extraDns;
        };
        oidc = {
          only_start_if_oidc_is_available = true;
          issuer = "https://id.ataraxiadev.com";
          client_id = "5f68c51b-f71c-4e5e-afb6-80c673fcde3a";
          client_secret_path = config.sops.secrets.headscale-oidc.path;
          scope = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          allowed_groups = [ "headscale" ];
        };
        pkce = {
          enabled = true;
          method = "S256";
        };
        grpc_listen_addr = "127.0.0.1:${ports.headscale-grpc.str}";
        grpc_allow_insecure = true;
        disable_check_updates = true;
        ephemeral_node_inactivity_timeout = "4h";
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/headscale." = {
          extraConfig = ''
            grpc_pass grpc://${config.services.headscale.settings.grpc_listen_addr};
          '';
          priority = 1;
        };
        locations."/metrics" = {
          proxyPass = "http://127.0.0.1:${ports.headscale.str}";
          extraConfig = ''
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            deny all;
          '';
          priority = 2;
        };
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.headscale.str}";
          proxyWebsockets = true;
          priority = 3;
        };
      };
    };

    sops.secrets.headscale-oidc = {
      sopsFile = secretsDir + /${cfg.sopsDir}/headscale.yaml;
      owner = "headscale";
      restartUnits = [ "headscale.service" ];
    };
    systemd.services.headscale = {
      serviceConfig.TimeoutStopSec = 15;
      serviceConfig.ExecStartPre =
        let
          waitOidcProviderReady = pkgs.writeShellScript "waitOidcProviderReady" ''
            # Check until pocket-id is alive
            max_retry=100
            counter=1
            until ${lib.getExe pkgs.curl} -fsSL http://id.ataraxiadev.com/healthz
            do
              echo "Waiting for the pocket-id..."
              sleep 3
              [[ counter -eq $max_retry ]] && echo "Could not connect to pocket-id!" && exit 1
              echo "Trying again. Try #$counter"
              ((counter++))
            done
            echo "pocket-id is alive!"
          '';
        in
        waitOidcProviderReady;
    };

    persist.state.directories = [ "/var/lib/headscale" ];
  };
}
