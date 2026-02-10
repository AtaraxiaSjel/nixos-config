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
  inherit (config.virtualisation.quadlet) containers networks pods;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.authentik;
  nginx = config.ataraxia.services.nginx;
  domain = "auth.ataraxiadev.com";

  authentik-version = "2025.8.3";
  postgres-version = "16-alpine";
in
{
  options.ataraxia.containers.authentik = {
    enable = mkEnableOption "Enable authentik container";
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
    sops.secrets =
      let
        sopsFile = secretsDir + /${cfg.sopsDir}/authentik.yaml;
      in
      {
        authentik-postgresql-env = {
          inherit sopsFile;
          restartUnits = [ containers.authentik-postgresql.ref ];
        };
        authentik-container-env = {
          inherit sopsFile;
          restartUnits = [
            containers.authentik-server.ref
            containers.authentik-worker.ref
          ];
        };
        authentik-ldap-env = {
          inherit sopsFile;
          restartUnits = [ containers.authentik-ldap.ref ];
        };
      };

    virtualisation.quadlet.pods.authentik = {
      podConfig = {
        networks = [ networks.br-services.ref ];
        publishPorts = [
          "127.0.0.1:${ports.authentik.str}:9000/tcp"
          "127.0.0.1:${ports.authentik-https.str}:9443/tcp"
        ];
      };
    };

    virtualisation.quadlet.containers = {
      authentik-postgresql = {
        autoStart = true;
        containerConfig = {
          environments = {
            POSTGRES_DB = "authentik";
            POSTGRES_USER = "authentik";
          };
          environmentFiles = [
            # POSTGRES_PASSWORD
            config.sops.secrets.authentik-postgresql-env.path
          ];
          # Health check
          healthCmd = "pg_isready -d \${POSTGRES_DB} -U \${POSTGRES_USER}";
          healthInterval = "30s";
          healthRetries = 5;
          healthStartPeriod = "30s";
          healthTimeout = "5s";
          pod = pods.authentik.ref;
          image = "docker.io/library/postgres:${postgres-version}";
          volumes = [ "/srv/authentik/database:/var/lib/postgresql/data" ];
        };
      };
      authentik-redis = {
        autoStart = true;
        containerConfig = {
          exec = "--save 60 1 --loglevel warning";
          # Health check
          healthCmd = "redis-cli ping | grep PONG";
          healthInterval = "30s";
          healthRetries = 5;
          healthStartPeriod = "30s";
          healthTimeout = "3s";
          pod = pods.authentik.ref;
          # Tags: alpine3.22, alpine, 8.4.0-alpine3.22
          image = "docker.io/library/redis@sha256:4eec4565e45aa0b3966554c866bc73211e281b0b3d89fe9a33c982e6faca809d";
          volumes = [ "/srv/authentik/redis:/data" ];
        };
      };
      authentik-server = {
        autoStart = true;
        containerConfig = {
          environments = {
            AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
            AUTHENTIK_REDIS__HOST = "authentik-redis";

            AUTHENTIK_DISABLE_UPDATE_CHECK = "true";
            AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
            AUTHENTIK_DISABLE_STARTUP_ANALYTICS = "true";
            AUTHENTIK_AVATARS = "initials";

            AUTHENTIK_EMAIL__HOST = "mail.ataraxiadev.com";
            AUTHENTIK_EMAIL__PORT = "465";
            AUTHENTIK_EMAIL__USE_SSL = "true";
            AUTHENTIK_EMAIL__TIMEOUT = "10";
            AUTHENTIK_EMAIL__USERNAME = "authentik@ataraxiadev.com";
            AUTHENTIK_EMAIL__FROM = "authentik@ataraxiadev.com";
          };
          environmentFiles = [
            # AUTHENTIK_POSTGRESQL__PASSWORD, AUTHENTIK_SECRET_KEY, AUTHENTIK_EMAIL__PASSWORD
            config.sops.secrets.authentik-container-env.path
          ];
          exec = "server";
          pod = pods.authentik.ref;
          image = "ghcr.io/goauthentik/server:${authentik-version}";
          volumes = [
            "/srv/authentik/media:/media"
            "/srv/authentik/custom-templates:/templates"
          ];
        };
        unitConfig = rec {
          After = [
            containers.authentik-postgresql.ref
            containers.authentik-redis.ref
          ];
          Requires = After;
        };
      };
      authentik-worker = {
        autoStart = true;
        containerConfig = {
          environments = containers.authentik-server.containerConfig.environments;
          environmentFiles = containers.authentik-server.containerConfig.environmentFiles;
          exec = "worker";
          pod = pods.authentik.ref;
          user = "root";
          # Tags: latest
          image = containers.authentik-server.containerConfig.image;
          volumes = [
            "/srv/authentik/media:/media"
            "/srv/authentik/custom-templates:/templates"
            "/srv/authentik/certs:/certs"
            "/var/run/docker.sock:/var/run/docker.sock"
            "/dev/shm:/dev/shm"
          ];
        };
        unitConfig = containers.authentik-server.unitConfig;
      };
      authentik-ldap = {
        autoStart = true;
        containerConfig = {
          environments = {
            AUTHENTIK_HOST = "https://auth.ataraxiadev.com";
            AUTHENTIK_INSECURE = "false";
          };
          environmentFiles = [
            # AUTHENTIK_TOKEN
            config.sops.secrets.authentik-ldap-env.path
          ];
          pod = pods.authentik.ref;
          image = "ghcr.io/goauthentik/ldap:${authentik-version}";
        };
        unitConfig = rec {
          After = [
            containers.authentik-server.ref
            containers.authentik-worker.ref
          ];
          Requires = After;
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/authentik 0700 root root -"
      "d /srv/authentik/database 0700 70 70 -"
      "d /srv/authentik/redis 0700 999 1000 -"
      "d /srv/authentik/media 0700 1000 1000 -"
      "d /srv/authentik/certs 0700 1000 1000 -"
      "d /srv/authentik/custom-templates 0700 1000 1000 -"
    ];

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.authentik.str}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
