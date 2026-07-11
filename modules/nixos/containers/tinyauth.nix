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
  inherit (config.virtualisation.quadlet) networks;
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
      restartUnits = [ "tinyauth.service" ];
    };

    virtualisation.quadlet.containers = {
      tinyauth = {
        autoStart = true;
        containerConfig = {
          environments = {
            TINYAUTH_APPURL = "https://${domain}";
            TINYAUTH_SERVER_PORT = ports.tinyauth.str;
            TINYAUTH_OAUTH_PROVIDERS_POCKETID_AUTHURL = "https://id.ataraxiadev.com/authorize";
            TINYAUTH_OAUTH_PROVIDERS_POCKETID_TOKENURL = "https://id.ataraxiadev.com/api/oidc/token";
            TINYAUTH_OAUTH_PROVIDERS_POCKETID_USERINFOURL = "https://id.ataraxiadev.com/api/oidc/userinfo";
            TINYAUTH_OAUTH_PROVIDERS_POCKETID_REDIRECTURL = "https://tinyauth.ataraxiadev.com/api/oauth/callback/pocketid";
            TINYAUTH_OAUTH_PROVIDERS_POCKETID_SCOPES = "openid email profile groups";
            TINYAUTH_OAUTH_PROVIDERS_POCKETID_NAME = "Pocket ID";
            TINYAUTH_LDAP_ADDRESS = "ldap://lldap:3890";
            TINYAUTH_LDAP_BINDDN = "uid=ldap-search,ou=people,dc=ataraxiadev,dc=com";
            TINYAUTH_LDAP_BASEDN = "dc=ataraxiadev,dc=com";
            TINYAUTH_LDAP_SEARCHFILTER = "(uid=%s)";
            TINYAUTH_LDAP_INSECURE = "true";
            TINYAUTH_AUTH_SECURECOOKIE = "true";
            TINYAUTH_ANALYTICS_ENABLED = "false";
            ZEROLOG_GLOBAL_LEVEL = "warn";
          };
          environmentFiles = [ config.sops.secrets.tinyauth-env.path ];
          healthCmd = "tinyauth healthcheck";
          healthInterval = "30s";
          healthRetries = 3;
          healthStartPeriod = "10s";
          healthTimeout = "5s";
          user = "${users.tinyauth.uidStr}:${users.tinyauth.gidStr}";
          # Tags: v5.0.7-distroless, v5.0-distroless, v5-distroless
          image = "ghcr.io/steveiliop56/tinyauth@sha256:e31ae2bac566cfe4687a8a54121a884ce25c4869995075f8e7e3d352bcd59241";
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
