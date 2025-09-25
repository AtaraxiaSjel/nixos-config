{
  config,
  lib,
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
  inherit (config.virtualisation.quadlet) containers networks;

  cfg = config.ataraxia.containers.tinyauth;
  nginx = config.ataraxia.services.nginx;
  domain = "tinyauth.ataraxiadev.com";
in
{
  options.ataraxia.containers.tinyauth = {
    enable = mkEnableOption "Enable tinyauth container";
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
    sops.secrets.tinyauth-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/tinyauth.yaml;
      restartUnits = [ containers.tinyauth.ref ];
    };

    virtualisation.quadlet.containers = {
      tinyauth = {
        autoStart = true;
        containerConfig = {
          environments = {
            APP_URL = "https://${domain}";
            PORT = "3100";
            DISABLE_CONTINUE = "true";
            GENERIC_AUTH_URL = "https://id.ataraxiadev.com/authorize";
            GENERIC_TOKEN_URL = "https://id.ataraxiadev.com/api/oidc/token";
            GENERIC_USER_URL = "https://id.ataraxiadev.com/api/oidc/userinfo";
            GENERIC_SCOPES = "openid email profile groups";
            GENERIC_NAME = "Pocket ID";
            # LDAP_ADDRESS = "ldap://lldap:3890";
            LDAP_BIND_DN = "uid=ldap-search,ou=people,dc=ataraxiadev,dc=com";
            LDAP_BASE_DN = "dc=ataraxiadev,dc=com";
            LDAP_SEARCH_FILTER = "(uid=%s)";
            LDAP_INSECURE = "true";
          };
          environmentFiles = [ config.sops.secrets.tinyauth-env.path ];
          # Tags: v3.6.2, v3.6, v3
          image = "ghcr.io/steveiliop56/tinyauth@sha256:6fb523a7bda58f1e6072c3a1c4bc0186ae0c45e79802ca6ac7d21136775807f3";
          networks = with networks; [
            br-services.ref
            lldap.ref
          ];
          publishPorts = [ "127.0.0.1:3100:3100/tcp" ];
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3100";
        };
      };
    };
  };
}
