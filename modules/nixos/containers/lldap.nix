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

  cfg = config.ataraxia.containers.lldap;
  nginx = config.ataraxia.services.nginx;
  domain = "ldap.ataraxiadev.com";

  uid = 391;
  gid = 391;
  uidStr = toString uid;
  gidStr = toString gid;
in
{
  options.ataraxia.containers.lldap = {
    enable = mkEnableOption "Enable lldap container";
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
    sops.secrets.lldap-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/lldap.yaml;
      restartUnits = [ containers.lldap.ref ];
    };

    virtualisation.quadlet.networks = {
      lldap.networkConfig = {
        disableDns = false;
        dns = [
          "10.10.10.9"
          "10.10.10.1"
        ];
        ipv6 = false;
      };
    };

    virtualisation.quadlet.containers = {
      lldap = {
        autoStart = true;
        containerConfig = {
          environments = {
            UID = uidStr;
            GID = gidStr;
            TZ = "UTC";
            LLDAP_HTTP_PORT = "6100";
            LLDAP_HTTP_URL = "https://ldap.ataraxiadev.com";
            LLDAP_LDAP_BASE_DN = "dc=ataraxiadev,dc=com";
            LLDAP_SMTP_OPTIONS__SERVER = "mail.ataraxiadev.com";
            LLDAP_SMTP_OPTIONS__PORT = "465";
            LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION = "TLS";
            LLDAP_SMTP_OPTIONS__USER = "ldap@ataraxiadev.com";
            LLDAP_SMTP_OPTIONS__FROM = "LLDAP <ldap@ataraxiadev.com>";
          };
          environmentFiles = [ config.sops.secrets.lldap-env.path ];
          healthCmd = "/app/lldap healthcheck";
          healthInterval = "30s";
          healthRetries = 3;
          healthStartPeriod = "20s";
          healthTimeout = "30s";

          user = "${uidStr}:${gidStr}";
          # Tags: stable-debian-rootless, v0.6-debian-rootless, v0-debian-rootless
          image = "docker.io/lldap/lldap@sha256:54e9bcd4ed6b98fa46864595c9b66ed8a66048dd26698ddff710f25bb980c433";
          networks = with networks; [
            br-services.ref
            lldap.ref
          ];
          publishPorts = [ "127.0.0.1:6100:6100/tcp" ];
          volumes = [ "/srv/lldap/data:/data" ];
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:6100";
        };
      };
    };

    users.users.lldap = {
      group = "lldap";
      isSystemUser = true;
      uid = uid;
    };
    users.groups.lldap.gid = gid;

    systemd.tmpfiles.rules = [
      "d /srv/lldap 0700 ${uidStr} ${gidStr} -"
      "d /srv/lldap/data 0700 ${uidStr} ${gidStr} -"
    ];
  };
}
