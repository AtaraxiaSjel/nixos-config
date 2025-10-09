{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.forgejo;
  nginx = config.ataraxia.services.nginx;
  domain = "git.ataraxiadev.com";

  forgejo-user = config.services.forgejo.user;
  forgejo-group = config.services.forgejo.group;
  forgejo-secret = {
    sopsFile = secretsDir + /${cfg.sopsDir}/forgejo.yaml;
    owner = forgejo-user;
    restartUnits = [ "forgejo.service" ];
  };
  nginx-user = config.services.nginx.user;
  useUnixSocket = true;
in
{
  options.ataraxia.services.forgejo = {
    enable = mkEnableOption "Enable forgejo service";
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
    sops.secrets = {
      forgejo-db-passwd = forgejo-secret;
      forgejo-internal-token = forgejo-secret;
      forgejo-jwt-secret = forgejo-secret;
      forgejo-lfs-jwt-secret = forgejo-secret;
      forgejo-mailer-passwd = forgejo-secret;
      forgejo-secret-key = forgejo-secret;
    };

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      database = {
        type = "sqlite3";
        passwordFile = config.sops.secrets.forgejo-db-passwd.path;
      };
      dump = {
        enable = true;
        backupDir = "/srv/forgejo/dump";
        interval = "04:35";
        type = "tar.zst";
      };
      lfs.enable = true;
      stateDir = "/srv/forgejo/data";
      secrets = {
        mailer = {
          PASSWD = config.sops.secrets.forgejo-mailer-passwd.path;
        };
        oauth2 = {
          JWT_SECRET = mkForce config.sops.secrets.forgejo-jwt-secret.path;
        };
        security = {
          INTERNAL_TOKEN = mkForce config.sops.secrets.forgejo-internal-token.path;
          SECRET_KEY = mkForce config.sops.secrets.forgejo-secret-key.path;
        };
        server = mkIf config.services.forgejo.lfs.enable {
          LFS_JWT_SECRET = mkForce config.sops.secrets.forgejo-lfs-jwt-secret.path;
        };
      };
      settings = {
        actions = {
          ENABLED = false;
        };
        api = {
          ENABLE_SWAGGER = false;
        };
        attachment = {
          MAX_FILES = 10;
          MAX_SIZE = 100;
        };
        cache = {
          ADAPTER = "twoqueue";
          HOST = "{\"size\":500, \"recent_ratio\":0.25, \"ghost_ratio\":0.5}";
        };
        cron = {
          ENABLED = true;
        };
        database = {
          SQLITE_JOURNAL_MODE = "WAL";
          # LOG_SQL = false;
        };
        # log = {
        #   MODE = "console";
        #   LEVEL = "Debug";
        #   ROUTER = "console";
        #   COLORIZE = false;
        #   ENABLE_SSH_LOG = false;
        # };
        mailer = {
          ENABLED = true;
          SMTP_ADDR = "mail.ataraxiadev.com";
          SMTP_PORT = "465";
          USER = "git@ataraxiadev.com";
          FROM = "Forgejo <git@ataraxiadev.com>";
        };
        openid = {
          ENABLE_OPENID_SIGNIN = false;
          ENABLE_OPENID_SIGNUP = false;
        };
        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
          UPDATE_AVATAR = true;
          ACCOUNT_LINKING = "login";
        };
        packages = {
          ENABLED = false;
        };
        repository = {
          DEFAULT_PRIVATE = "private";
        };
        "repository.upload" = {
          FILE_MAX_SIZE = 100;
          MAX_FILES = 10;
        };
        "repository.signing" = {
          DEFAULT_TRUST_MODEL = "committer";
        };
        security = {
          COOKIE_REMEMBER_NAME = "forgejo_auth";
          DISABLE_GIT_HOOKS = true;
          DISABLE_WEBHOOKS = false;
          IMPORT_LOCAL_PATHS = false;
          INSTALL_LOCK = true;
          LOGIN_REMEMBER_DAYS = 14;
          PASSWORD_HASH_ALGO = "argon2";
        };
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}";
          PROTOCOL = if useUnixSocket then "http+unix" else "http";
          HTTP_ADDR = if useUnixSocket then "/run/forgejo/forgejo.sock" else "127.0.0.1";
          HTTP_PORT = mkIf (!useUnixSocket) ports.forgejo.int;
          UNIX_SOCKET_PERMISSION = "660";
          SSH_PORT = 22;
          COOKIE_SECURE = true;
          ENABLE_GZIP = true;
          OFFLINE_MODE = true;
        };
        service = {
          DEFAULT_ALLOW_CREATE_ORGANIZATION = false;
          DEFAULT_KEEP_EMAIL_PRIVATE = true;
          DEFAULT_USER_IS_RESTRICTED = false;
          DISABLE_REGISTRATION = true;
          EMAIL_DOMAIN_ALLOWLIST = "ataraxiadev.com";
          ENABLE_BASIC_AUTHENTICATION = false;
          ENABLE_INTERNAL_SIGNIN = false; # Homelab oidc only
          ENABLE_NOTIFY_MAIL = true;
          REGISTER_EMAIL_CONFIRM = false;
          REGISTER_MANUAL_CONFIRM = true;
        };
        session = {
          COOKIE_NAME = "forgejo_session";
        };
        ui = {
          DEFAULT_THEME = "forgejo-dark";
        };
        webhook = {
          ALLOWED_HOST_LIST = "loopback,private,ataraxiadev.com,*.ataraxiadev.com";
        };
      };
    };

    services.openssh.settings = {
      AcceptEnv = "GIT_PROTOCOL";
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass =
            if useUnixSocket then
              "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}:/"
            else
              "http://127.0.0.1:${ports.forgejo.str}";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 512M;
          '';
        };
      };
    };
    users.users.${nginx-user}.extraGroups = mkIf useUnixSocket [ forgejo-group ];

    # Custom secrets workaround
    systemd.services.forgejo-secrets.script = mkForce "exit 0";

    systemd.services.forgejo-dump-clean =
      let
        older-than = "3"; # in days
      in
      rec {
        before = [ "forgejo-dump.service" ];
        requiredBy = before;
        script = ''
          ${pkgs.findutils}/bin/find ${config.services.forgejo.dump.backupDir} \
            -mindepth 1 -type f -mtime +${older-than} -delete
        '';
      };
  };
}
