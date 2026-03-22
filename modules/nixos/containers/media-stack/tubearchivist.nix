{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) str;
  inherit (config.virtualisation.quadlet) containers pods;

  cfg = config.ataraxia.containers.media-stack;
  hostname = config.networking.hostName;

  nas-path = "/media/nas/media-stack";
  proxy = "http://10.10.10.6:8888";

  apply-proxy = pkgs.writeScript "applyproxy.sh" ''
    #!/bin/bash

    echo "Applying proxy to yt-dlp..."
    find /app/ -iname 'yt_dlp_base.py' -exec sed -i 's; "retries": 10,;"proxy": "${proxy}","retries": 10,;g' {} \;

    echo "Starting tubearchivist..."
    /app/run.sh
  '';
in
{
  options.ataraxia.containers.media-stack = {
    tubearchivist = mkEnableOption "Enable tubearchivist container";
    sopsDir = mkOption {
      type = str;
      default = hostname;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.tubearchivist {
    sops.secrets.tubearchivist-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/tubearchivist.yaml;
      restartUnits = [
        "archivist-es.service"
        "tubearchivist.service"
      ];
    };
    virtualisation.quadlet.containers = {
      tubearchivist = {
        autoStart = true;
        containerConfig = {
          # Tags: v0.5.9, unstable
          image = "docker.io/bbilly1/tubearchivist@sha256:b827a713f55b2b1933f8b130f36dc8b38cec3dd56998c389b7c9694a7238f3df";
          pod = pods.media-stack.ref;
          entrypoint = "/applyproxy.sh";
          environments = {
            HOST_UID = "1000";
            HOST_GID = "100";
            TZ = "Europe/Moscow";
            ES_URL = "http://archivist-es:9200";
            REDIS_CON = "redis://archivist-redis:6379";
            TA_PORT = "8000";
            TA_BACKEND_PORT = "8001";
            TA_HOST = "https://tube.ataraxiadev.com";
            TA_USERNAME = "ataraxia";
            # LDAP
            TA_LOGIN_AUTH_MODE = "ldap";
            TA_LDAP_SERVER_URI = "ldap://lldap:3890";
            TA_LDAP_BIND_DN = "uid=ldap-search,ou=people,dc=ataraxiadev,dc=com";
            TA_LDAP_USER_BASE = "ou=people,dc=ataraxiadev,dc=com";
            TA_LDAP_USER_FILTER = "(&(objectClass=person)(memberOf=cn=Homelab Users,ou=groups,dc=ataraxiadev,dc=com))";
            TA_LDAP_PROMOTE_USERNAMES_TO_SUPERUSER = "ataraxiadev";
          };
          environmentFiles = [ config.sops.secrets.tubearchivist-env.path ];
          healthCmd = "curl -f http://localhost:8000/api/health/";
          healthInterval = "2m";
          healthRetries = 3;
          healthStartPeriod = "30s";
          healthTimeout = "10s";
          volumes = [
            "${nas-path}/configs/tubearchivist/cache:/cache"
            "${nas-path}/media/youtube:/youtube"
            "${apply-proxy}:/applyproxy.sh:ro"
          ];
        };
        unitConfig = rec {
          After = [
            containers.archivist-es.ref
            containers.archivist-redis.ref
          ];
          Requires = After;
        };
      };
      archivist-es = {
        autoStart = true;
        containerConfig = {
          # Tags: 8.19.0
          image = "docker.io/bbilly1/tubearchivist-es@sha256:9da63fb1973ec3d57daf6916be948eddd0d8a404cc8e447c938480c85fe2c554";
          pod = pods.media-stack.ref;
          environments = {
            ES_JAVA_OPTS = "-Xms1g -Xmx1g";
            "xpack.security.enabled" = "true";
            "discovery.type" = "single-node";
            "path.repo" = "/usr/share/elasticsearch/data/snapshot";
          };
          environmentFiles = [ config.sops.secrets.tubearchivist-env.path ];
          ulimits = [ "memlock=-1:-1" ];
          volumes = [ "${nas-path}/configs/tubearchivist/es:/usr/share/elasticsearch/data" ];
        };
      };
      archivist-redis = {
        autoStart = true;
        containerConfig = {
          # Tags: alpine3.23, alpine, 8.6.1-alpine3.23
          image = "docker.io/library/redis@sha256:2afba59292f25f5d1af200496db41bea2c6c816b059f57ae74703a50a03a27d0";
          pod = pods.media-stack.ref;
          volumes = [ "${nas-path}/configs/tubearchivist/redis:/data" ];
        };
      };
    };
  };
}
