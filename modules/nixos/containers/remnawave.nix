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
  inherit (config.ataraxia.lists) ports;
  inherit (config.virtualisation.quadlet)
    containers
    networks
    pods
    volumes
    ;

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
          "127.0.0.1:${ports.remna-app.str}:3000/tcp"
          # "127.0.0.1:${ports.remna-metrics.str}:3001/tcp"
          "127.0.0.1:${ports.remna-sub.str}:3010/tcp"
          # "127.0.0.1:${ports.remna-db.str}:5432/tcp"
        ];
      };
    };

    virtualisation.quadlet.volumes = {
      valkey-socket = {
        volumeConfig = {
          name = "valkey-socket";
        };
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
          # updater: track=18
          # Tags: 18, latest, 18.6
          image = "docker.io/library/postgres@sha256:86c951e05bf56c93d95d397747fb8820ac76cc3bedb78f43abd83eedbe3666ae";
          volumes = [ "/srv/remnawave/database:/var/lib/postgresql" ];
        };
      };
      remnawave-redis = {
        autoStart = true;
        containerConfig = {
          # Health check
          healthCmd = "valkey-cli -s /var/run/valkey/valkey.sock ping";
          healthInterval = "3s";
          healthRetries = 5;
          healthStartPeriod = "3s";
          healthTimeout = "3s";
          pod = pods.remnawave.ref;
          exec = [
            "valkey-server"
            "--save \"\""
            "--appendonly no"
            "--maxmemory-policy noeviction"
            "--loglevel warning"
            "--unixsocket /var/run/valkey/valkey.sock"
            "--unixsocketperm 777"
            "--port 0"
          ];
          # updater: track=9-alpine
          # Tags: 9-alpine, 9.1.2-alpine, 9.1.2-alpine3.24
          image = "docker.io/valkey/valkey@sha256:48332870af354a799964c0012ae1194a0bf2bf894eb508f945810596dc2d8d11";
          volumes = [ "${volumes.valkey-socket.ref}:/var/run/valkey" ];
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
            REDIS_SOCKET = "/var/run/valkey/valkey.sock";
            API_INSTANCES = "1";
            IS_TELEGRAM_NOTIFICATIONS_ENABLED = "false";
            FRONT_END_DOMAIN = domain;
            SUB_PUBLIC_DOMAIN = subs-domain;
            WEBHOOK_ENABLED = "false";
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
          # updater: track=3
          # Tags: 3, latest, 3.4.4
          image = "docker.io/remnawave/backend@sha256:63ef481550bbf49dabfa514c95d94109619cc85607730b308f7ad0b9b5599f06";
          volumes = [ "${volumes.valkey-socket.ref}:/var/run/valkey" ];
        };
        unitConfig = rec {
          After = [
            containers.remnawave-db.ref
            containers.remnawave-redis.ref
          ];
          Wants = After;
        };
      };
      remnawave-subscription-page = {
        autoStart = true;
        containerConfig = {
          environments = {
            REMNAWAVE_PANEL_URL = "http://remnawave:${containers.remnawave-panel.containerConfig.environments.APP_PORT}";
            APP_PORT = "3010";
          };
          environmentFiles = [ config.sops.secrets.remnawave-subs-env.path ];
          pod = pods.remnawave.ref;
          # Tags: latest, 8.0.0
          image = "docker.io/remnawave/subscription-page@sha256:04e8d479afb3598024e4018e9e15cd7fe879938250090a690ba39f1ee91b79ac";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/remnawave 0700 root root -"
      "d /srv/remnawave/database 0755 root root -"
    ];

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.remna-app.str}";
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
          proxyPass = "http://127.0.0.1:${ports.remna-sub.str}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
