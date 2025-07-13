{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;

  cfg = config.ataraxia.services.ntfy-sh;
  nginx = config.ataraxia.services.nginx;
  domain = "ntfy.ataraxiadev.com";
  port = "2586";
in
{
  options.ataraxia.services.ntfy-sh = {
    enable = mkEnableOption "Enable ntfy-sh service";
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
  };

  config = mkIf cfg.enable {
    sops.secrets.ntfy-firebase = {
      sopsFile = secretsDir + /${cfg.sopsDir}/ntfy.yaml;
      owner = config.services.ntfy-sh.user;
      restartUnits = [ "ntfy-sh.service" ];
    };

    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${domain}";
        listen-http = "127.0.0.1:${port}";
        behind-proxy = cfg.nginxHost;

        attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
        auth-default-access = "deny-all";
        auth-file = "/var/lib/ntfy-sh/user.db";
        cache-file = "/var/lib/ntfy-sh/cache.db";
        firebase-key-file = config.sops.secrets.ntfy-firebase.path;
      };
    };

    systemd.services.ntfy-sh = {
      serviceConfig = {
        User = mkForce config.services.ntfy-sh.user;
        Group = mkForce config.services.ntfy-sh.group;
        DynamicUser = mkForce false;
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_connect_timeout 3m;
            proxy_send_timeout 3m;
            proxy_read_timeout 3m;

            client_max_body_size 0; # Stream request body to backend
          '';
        };
      };
    };

    persist.state.directories = [ "/var/lib/ntfy-sh" ];
  };
}
