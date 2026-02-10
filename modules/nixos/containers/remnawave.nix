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

  cfg = config.ataraxia.containers.remnawave;
  nginx = config.ataraxia.services.nginx;
  domain = "wave.ataraxiadev.com";
  subs-domain = "sub.ataraxiadev.com";

  postgres-version = "17-alpine";
in
{
  options.ataraxia.containers.remnawave = {
    enable = mkEnableOption "Enable remnawave control panel";
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
        sopsFile = secretsDir + /${cfg.sopsDir}/remnawave.yaml;
      in
      {
        remnawave-db-env = {
          inherit sopsFile;
          restartUnits = [ "remnawave-db.service" ];
        };
        remnawave-panel-env = {
          inherit sopsFile;
          restartUnits = [ "remnawave-panel.service" ];
        };
        remnawave-subs-env = {
          inherit sopsFile;
          restartUnits = [ "remnawave-subscription-page.service" ];
        };
      };

    virtualisation.quadlet.pods.remnawave = {
      podConfig = {
        networks = [ networks.br-services.ref ];
        publishPorts = [
          "127.0.0.1:3000:3000/tcp"
          "127.0.0.1:3001:3001/tcp"
          "127.0.0.1:3010:3010/tcp"
          "127.0.0.1:6767:5432/tcp"
        ];
      };
    };

    virtualisation.quadlet.containers = {
      remnawave-db = {
        autoStart = true;
        containerConfig = {
          environments = {
            POSTGRES_DB = "postgres";
            POSTGRES_USER = "postgres";
            TZ = "UTC";
          };
          environmentFiles = [ config.sops.secrets.remnawave-db-env.path ];
          # Health check
          healthCmd = "pg_isready -d \${POSTGRES_DB} -U \${POSTGRES_USER}";
          healthInterval = "10s";
          healthRetries = 5;
          healthStartPeriod = "10s";
          healthTimeout = "10s";
          pod = pods.remnawave.ref;
          image = "docker.io/library/postgres:${postgres-version}";
          volumes = [ "/srv/remnawave/database:/var/lib/postgresql/data" ];
        };
      };
      remnawave-redis = {
        autoStart = true;
        containerConfig = {
          # Health check
          healthCmd = "valkey-cli ping | grep PONG";
          healthInterval = "10s";
          healthRetries = 5;
          healthStartPeriod = "10s";
          healthTimeout = "10s";
          pod = pods.remnawave.ref;
          # Tags: 8-alpine3.23, 8.1-alpine3.23, 8.1.5-alpine3.23
          image = "docker.io/valkey/valkey@sha256:3c3ccc8571d4866ec5ac5ffb2519b6b6a1fdbf6b5ff5fdab075413026fbff273";
          volumes = [ "/srv/remnawave/redis:/data" ];
        };
      };
      remnawave-panel = {
        autoStart = true;
        containerConfig = {
          name = "remnawave";
          hostname = "remnawave";
          environments = {
            APP_PORT = "3000";
            METRICS_PORT = "3001";
            API_INSTANCES = "1";
            REDIS_HOST = "remnawave-redis";
            REDIS_PORT = "6379";
            IS_TELEGRAM_NOTIFICATIONS_ENABLED = "false";
            TELEGRAM_OAUTH_ENABLED = "false";
            FRONT_END_DOMAIN = domain;
            SUB_PUBLIC_DOMAIN = subs-domain;
            SWAGGER_PATH = "/docs";
            SCALAR_PATH = "/scalar";
            IS_DOCS_ENABLED = "false";
            WEBHOOK_ENABLED = "false";
            HWID_DEVICE_LIMIT_ENABLED = "false";
            BANDWIDTH_USAGE_NOTIFICATIONS_ENABLED = "false";
            BANDWIDTH_USAGE_NOTIFICATIONS_THRESHOLD = "[60, 80]";
          };
          environmentFiles = [ config.sops.secrets.remnawave-panel-env.path ];
          # Health check
          healthCmd = "curl -f http://localhost:\${METRICS_PORT:-3001}/health";
          healthInterval = "30s";
          healthRetries = 5;
          healthStartPeriod = "30s";
          healthTimeout = "5s";
          pod = pods.remnawave.ref;
          # Tags: 2, 2.6.0
          image = "docker.io/remnawave/backend@sha256:be0a158deabf67396f5c1e30458dcba202ab1c0558f12cb9874d2bc2c0604617";
        };
        unitConfig = rec {
          After = [
            containers.remnawave-db.ref
            containers.remnawave-redis.ref
          ];
          Requires = After;
        };
      };
      remnawave-subscription-page = {
        autoStart = true;
        containerConfig = {
          environments = {
            REMNAWAVE_PANEL_URL = "https://${domain}";
            APP_PORT = "3010";
          };
          environmentFiles = [ config.sops.secrets.remnawave-subs-env.path ];
          pod = pods.remnawave.ref;
          # Tags: 7.1.7
          image = "docker.io/remnawave/subscription-page@sha256:1d4737d0d1647344afa9fc49bdb8de340b2af32b3f078db4bc4e83baec3e8450";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/remnawave 0700 root root -"
      "d /srv/remnawave/database 0700 70 70 -"
      "d /srv/remnawave/redis 0700 999 1000 -"
    ];

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
        extraConfig = ''
          allow 127.0.0.1/32;
          allow 100.64.0.0/16;
          allow 10.10.10.0/24;
          allow fd7a:115c:a1e0::/64;
          deny all;
        '';
      };
      ${subs-domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3010";
          proxyWebsockets = true;
        };
      };
    };
  };
}
