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

  cfg = config.ataraxia.containers.pocket-id;
  nginx = config.ataraxia.services.nginx;
  domain = "id.ataraxiadev.com";
in
{
  options.ataraxia.containers.pocket-id = {
    enable = mkEnableOption "Enable pocket-id container";
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
    sops.secrets.pocket-id-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/pocketid.yaml;
      restartUnits = [ "pocket-id.service" ];
    };

    virtualisation.quadlet.containers = {
      pocket-id = {
        autoStart = true;
        containerConfig = {
          environments = {
            APP_URL = "https://${domain}";
            # INTERNAL_APP_URL = "http://pocket-id:1411";
            PORT = ports.pocket-id.str;
            TRUST_PROXY = "true";
            KEYS_STORAGE = "database";
            ANALYTICS_DISABLED = "true";
            UI_CONFIG_DISABLED = "true";
            ACCENT_COLOR = "e84461";
            SMTP_HOST = "mail.ataraxiadev.com";
            SMTP_PORT = "465";
            SMTP_FROM = "Pocket ID <id@ataraxiadev.com>";
            SMTP_USER = "id@ataraxiadev.com";
            SMTP_TLS = "tls";
            EMAIL_LOGIN_NOTIFICATION_ENABLED = "false";
            EMAIL_ONE_TIME_ACCESS_AS_ADMIN_ENABLED = "false";
            EMAIL_API_KEY_EXPIRATION_ENABLED = "true";
            EMAIL_ONE_TIME_ACCESS_AS_UNAUTHENTICATED_ENABLED = "false";
            LDAP_ENABLED = "true";
            LDAP_URL = "ldap://lldap:3890";
            LDAP_BIND_DN = "uid=ldap-search,ou=people,dc=ataraxiadev,dc=com";
            LDAP_BASE = "dc=ataraxiadev,dc=com";
            LDAP_USER_SEARCH_FILTER = "(&(objectClass=person)(memberOf=cn=Homelab Users,ou=groups,dc=ataraxiadev,dc=com))";
            LDAP_USER_GROUP_SEARCH_FILTER = "(&(objectClass=groupOfNames)(importable=yes))";
            LDAP_SKIP_CERT_VERIFY = "false";
            LDAP_SOFT_DELETE_USERS = "false";
            LDAP_ATTRIBUTE_USER_UNIQUE_IDENTIFIER = "uuid";
            LDAP_ATTRIBUTE_USER_USERNAME = "uid";
            LDAP_ATTRIBUTE_USER_EMAIL = "mail";
            LDAP_ATTRIBUTE_USER_FIRST_NAME = "givenName";
            LDAP_ATTRIBUTE_USER_LAST_NAME = "sn";
            LDAP_ATTRIBUTE_USER_DISPLAY_NAME = "cn";
            LDAP_ATTRIBUTE_USER_PROFILE_PICTURE = "jpegPhoto";
            LDAP_ATTRIBUTE_GROUP_MEMBER = "member";
            LDAP_ATTRIBUTE_GROUP_UNIQUE_IDENTIFIER = "uuid";
            LDAP_ATTRIBUTE_GROUP_NAME = "cn";
            LDAP_ATTRIBUTE_ADMIN_GROUP = "Pocket ID Admins";
          };
          environmentFiles = [ config.sops.secrets.pocket-id-env.path ];
          healthCmd = "/app/pocket-id healthcheck";
          healthInterval = "1m30s";
          healthRetries = 2;
          healthStartPeriod = "20s";
          healthTimeout = "5s";
          user = "${users.pocket-id.uidStr}:${users.pocket-id.gidStr}";
          readOnly = true;
          # Tags: v1.13.1-distroless, v1.13-distroless, latest-distroless
          image = "ghcr.io/pocket-id/pocket-id@sha256:fa9dd24ed11d94218110c2c3f8814120d661ea6dc490ff21cf1562f710bc3f0d";
          networks = with networks; [
            br-services.ref
            lldap.ref
          ];
          publishPorts = [ "127.0.0.1:${ports.pocket-id.str}:1411/tcp" ];
          volumes = [ "/srv/pocket-id/data:/app/data" ];
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.pocket-id.str}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_busy_buffers_size     512k;
            proxy_buffers             4 512k;
            proxy_buffer_size           256k;
          '';
        };
      };
    };

    users.users.${users.pocket-id.name} = {
      isSystemUser = true;
      group = users.pocket-id.name;
      uid = users.pocket-id.uid;
    };
    users.groups.${users.pocket-id.name}.gid = users.pocket-id.gid;

    systemd.tmpfiles.rules = [
      "d /srv/pocket-id 0700 ${users.pocket-id.uidStr} ${users.pocket-id.gidStr} -"
      "d /srv/pocket-id/data 0700 ${users.pocket-id.uidStr} ${users.pocket-id.gidStr} -"
    ];
  };
}
