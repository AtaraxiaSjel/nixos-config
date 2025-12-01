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
          restartUnits = [ containers.remnawave-db.ref ];
        };
        remnawave-panel-env = {
          inherit sopsFile;
          restartUnits = [ containers.remnawave-panel.ref ];
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
          # Tags: 8-alpine3.22, 8.1-alpine3.22, 8.1.4-alpine3.22
          image = "docker.io/valkey/valkey@sha256:e706d1213aaba6896c162bb6a3a9e1894e1a435f28f8f856d14fab2e10aa098b";
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
          # Tags: 2, 2.2.6
          image = "docker.io/remnawave/backend@sha256:72ba44ca6a35ed7e328f551d08eb93a14328e5e6017718d3e326eea8cf19dca2";
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
            META_TITLE = "Subscriptions";
            META_DESCRIPTION = "Subscription Page Description";
          };
          pod = pods.remnawave.ref;
          # Tags: 6.0.8
          image = "docker.io/remnawave/subscription-page@sha256:ed680e166622e1ac834fd23669228cd7b28933b117e0a1f5f0c2d1285d9cf9be";
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
