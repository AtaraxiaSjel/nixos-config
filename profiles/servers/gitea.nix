{ pkgs, config, lib, ... }:
let
  user = config.services.gitea.user;
  group = "gitea";
in {
  secrets.gitea.owner = user;
  secrets.gitea-mailer.owner = user;
  secrets.gitea-secretkey.owner = user;
  secrets.gitea-internaltoken.owner = user;

  persist.state.directories = lib.mkIf
    (config.deviceSpecific.devInfo.fileSystem != "zfs") [{
      directory = "/srv/gitea";
      inherit user group;
    }];

  # TODO: backups! gitea.dump setting
  services.gitea = {
    enable = true;
    appName = "AtaraxiaDev's Gitea Instance";
    database = {
      type = "postgres";
      passwordFile = config.secrets.gitea.decrypted;
    };
    # TODO: cleanup cache older than...
    dump = {
      enable = true;
      backupDir = "/srv/gitea/dump";
      interval = "daily";
      type = "tar.zst";
    };
    domain = "code.ataraxiadev.com";
    httpAddress = "127.0.0.1";
    httpPort = 6000;
    lfs.enable = true;
    rootUrl = "https://code.ataraxiadev.com";
    stateDir = "/srv/gitea/data";
    mailerPasswordFile = config.secrets.gitea-mailer.decrypted;
    settings = {
      api = {
        ENABLE_SWAGGER = false;
      };
      attachment = {
        MAX_SIZE = 100;
        MAX_FILES = 10;
      };
      mailer = {
        ENABLED = true;
        # PROTOCOL = "smtp+starttls";
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.ataraxiadev.com";
        USER = "gitea@ataraxiadev.com";
      };
      migrations = {
        ALLOWED_DOMAINS = "github.com, *.github.com, gitlab.com, *.gitlab.com";
      };
      packages = {
        ENABLED = false;
      };
      # repository = {
      #   DISABLE_HTTP_GIT = true;
      # };
      "repository.upload" = {
        FILE_MAX_SIZE = 100;
        MAX_FILES = 10;
      };
      security = {
        INSTALL_LOCK = true;
        DISABLE_GIT_HOOKS = true;
        DISABLE_WEBHOOKS = true;
        IMPORT_LOCAL_PATHS = false;
        PASSWORD_HASH_ALGO = "argon2";
        SECRET_KEY_URI = "file:${config.secrets.gitea-secretkey.decrypted}";
        INTERNAL_TOKEN_URI = "file:${config.secrets.gitea-internaltoken.decrypted}";

        SECRET_KEY = lib.mkForce "";
        INTERNAL_TOKEN = lib.mkForce "";
      };
      oauth2 = {
        JWT_SIGNING_ALGORITHM = "ES256";
        JWT_SECRET = lib.mkForce "";
      };
      service = {
        DISABLE_REGISTRATION = true;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = false;
        DEFAULT_USER_IS_RESTRICTED = true;

        # REGISTER_EMAIL_CONFIRM = true;
        REGISTER_EMAIL_CONFIRM = false;
        REGISTER_MANUAL_CONFIRM = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
      ui = {
        DEFAULT_THEME = "arc-green";
      };
    };
  };
}