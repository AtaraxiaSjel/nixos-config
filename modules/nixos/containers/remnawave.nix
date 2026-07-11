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

  # postgres-version = "17-alpine";
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
          image = "docker.io/library/postgres@sha256:6f30057d31f5861b66f3545d4821f987aacf1dd920765f0acadea0c58ff975b1";
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
          # Tags: 8-alpine3.23, 8.1-alpine3.23, 8.1.8-alpine3.23
          image = "docker.io/valkey/valkey@sha256:77643d152547b446fc15cbafaff22004545663fcd40c6b28038ad283837baa75";
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
          # Tags: 2, 2.7.4
          image = "docker.io/remnawave/backend@sha256:a0e9a3d52e898b894965baed38ee45245b2cdb59ba19e198ab6371319e2968fc";
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
          # Tags: 7.2.5
          image = "docker.io/remnawave/subscription-page@sha256:3b8160459fe03ba875a8ac0f5c073959de27221186b5bda188d1785b3869cf4a";
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
