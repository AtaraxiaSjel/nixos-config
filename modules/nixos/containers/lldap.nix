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

  cfg = config.ataraxia.containers.lldap;
  nginx = config.ataraxia.services.nginx;
  domain = "ldap.ataraxiadev.com";
  inherit (config.ataraxia.lists) ports users;
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
      restartUnits = [ "lldap.service" ];
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
            UID = users.lldap.uidStr;
            GID = users.lldap.gidStr;
            TZ = "UTC";
            LLDAP_HTTP_PORT = ports.lldap-web.str;
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

          user = "${users.lldap.uidStr}:${users.lldap.gidStr}";
          # Tags: stable-debian-rootless, v0.6-debian-rootless, v0-debian-rootless
          image = "docker.io/lldap/lldap@sha256:54e9bcd4ed6b98fa46864595c9b66ed8a66048dd26698ddff710f25bb980c433";
          networks = with networks; [
            br-services.ref
            lldap.ref
          ];
          publishPorts = [
            "127.0.0.1:${ports.lldap-web.str}:${ports.lldap-web.str}/tcp"
            "0.0.0.0:3890:3890/tcp"
          ];
          volumes = [ "/srv/lldap/data:/data" ];
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.lldap-web.str}";
        };
      };
    };

    users.users.${users.lldap.name} = {
      isSystemUser = true;
      group = users.lldap.name;
      uid = users.lldap.uid;
    };
    users.groups.${users.lldap.name}.gid = users.lldap.gid;

    systemd.tmpfiles.rules = [
      "d /srv/lldap 0700 ${users.lldap.uidStr} ${users.lldap.gidStr} -"
      "d /srv/lldap/data 0700 ${users.lldap.uidStr} ${users.lldap.gidStr} -"
    ];
  };
}
