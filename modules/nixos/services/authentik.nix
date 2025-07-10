{
  config,
  lib,
  inputs,
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
  inherit (lib.types) bool str;

  cfg = config.ataraxia.services.authentik;
  nginx = config.ataraxia.services.nginx;
  domain = "auth.ataraxiadev.com";
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.authentik ];

  options.ataraxia.services.authentik = {
    enable = mkEnableOption "Enable authentik service";
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
    sops.secrets.authentik-env.sopsFile = secretsDir + /${cfg.sopsDir}/authentik.yaml;
    sops.secrets.authentik-ldap.sopsFile = secretsDir + /${cfg.sopsDir}/authentik.yaml;
    sops.secrets.authentik-env.restartUnits = [
      "authentik-server.service"
      "authentik-worker.service"
    ];
    sops.secrets.authentik-ldap.restartUnits = [ "authentik-ldap-outpost.service" ];

    backups.postgresql.authentik = { };

    services.authentik = {
      enable = true;
      logLevel = "info";
      listen.address = "127.0.0.1";
      listen.http = 9000;
      listen.https = 9443;
      environmentFile = config.sops.secrets.authentik-env.path;
      outposts.ldap = {
        enable = true;
        host = "https://${domain}";
        environmentFile = config.sops.secrets.authentik-ldap.path;
        listen.address = "127.0.0.1";
        listen.ldap = 3389;
        listen.ldaps = 6636;
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.authentik.listen.http}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
