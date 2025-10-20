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
  inherit (config.ataraxia.lists) ports users;

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
            PORT = ports.tinyauth.str;
            PROVIDERS_POCKETID_AUTH_URL = "https://id.ataraxiadev.com/authorize";
            PROVIDERS_POCKETID_TOKEN_URL = "https://id.ataraxiadev.com/api/oidc/token";
            PROVIDERS_POCKETID_USER_INFO_URL = "https://id.ataraxiadev.com/api/oidc/userinfo";
            PROVIDERS_POCKETID_SCOPES = "openid email profile groups";
            PROVIDERS_POCKETID_NAME = "Pocket ID";
            # LDAP_ADDRESS = "ldap://lldap:3890";
            LDAP_BIND_DN = "uid=ldap-search,ou=people,dc=ataraxiadev,dc=com";
            LDAP_BASE_DN = "dc=ataraxiadev,dc=com";
            LDAP_SEARCH_FILTER = "(uid=%s)";
            LDAP_INSECURE = "true";
            SECURE_COOKIE = "true";
            DISABLE_ANALYTICS = "true";
          };
          environmentFiles = [ config.sops.secrets.tinyauth-env.path ];
          healthCmd = "tinyauth healthcheck";
          healthInterval = "30s";
          healthRetries = 3;
          healthStartPeriod = "10s";
          healthTimeout = "5s";
          user = "${users.tinyauth.uidStr}:${users.tinyauth.gidStr}";
          # Tags: v4.0-distroless, v4.0.1-distroless, v4-distroless
          image = "ghcr.io/steveiliop56/tinyauth@sha256:3f4e251f5e184da1ab0627c45b056453f18259c3bb231edbb4a9347ba741a73f";
          networks = with networks; [
            br-services.ref
            lldap.ref
          ];
          publishPorts = [ "127.0.0.1:${ports.tinyauth.str}:${ports.tinyauth.str}/tcp" ];
          volumes = [ "/srv/tinyauth/data:/data" ];
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.tinyauth.str}";
        };
      };
    };

    users.users.${users.tinyauth.name} = {
      isSystemUser = true;
      group = users.tinyauth.name;
      uid = users.tinyauth.uid;
    };
    users.groups.${users.tinyauth.name}.gid = users.tinyauth.gid;

    systemd.tmpfiles.rules = [
      "d /srv/tinyauth 0700 ${users.tinyauth.uidStr} ${users.tinyauth.gidStr} -"
      "d /srv/tinyauth/data 0700 ${users.tinyauth.uidStr} ${users.tinyauth.gidStr} -"
    ];
  };
}
