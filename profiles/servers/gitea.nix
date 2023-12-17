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
    package = pkgs.gitea;
    appName = "AtaraxiaDev's Gitea Instance";
    database = {
      type = "postgres";
      passwordFile = config.secrets.gitea.decrypted;
    };
    dump = {
      enable = true;
      backupDir = "/srv/gitea/dump";
      interval = "06:00";
      type = "tar.zst";
    };
    lfs.enable = true;
    stateDir = "/srv/gitea/data";
    mailerPasswordFile = config.secrets.gitea-mailer.decrypted;
    settings = {
      server = {
        DOMAIN = "code.ataraxiadev.com";
        HTTP_ADDRESS = "127.0.0.1";
        HTTP_PORT = 6000;
        ROOT_URL = "https://code.ataraxiadev.com";
      };
      actions = {
        ENABLED = true;
      };
      api = {
        ENABLE_SWAGGER = false;
      };
      attachment = {
        MAX_SIZE = 100;
        MAX_FILES = 10;
      };
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.ataraxiadev.com";
        USER = "gitea@ataraxiadev.com";
      };
      migrations = {
        ALLOW_LOCALNETWORKS = true;
        ALLOWED_DOMAINS = "";
      };
      packages = {
        ENABLED = false;
      };
      "repository.upload" = {
        FILE_MAX_SIZE = 100;
        MAX_FILES = 10;
      };
      security = {
        INSTALL_LOCK = true;
        DISABLE_GIT_HOOKS = true;
        DISABLE_WEBHOOKS = false;
        IMPORT_LOCAL_PATHS = false;
        PASSWORD_HASH_ALGO = "argon2";
      };
      oauth2 = {
        JWT_SIGNING_ALGORITHM = "ES256";
      };
      service = {
        DISABLE_REGISTRATION = true;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = false;
        DEFAULT_USER_IS_RESTRICTED = true;
        REGISTER_EMAIL_CONFIRM = false;
        REGISTER_MANUAL_CONFIRM = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
      ui = {
        DEFAULT_THEME = "arc-green";
      };
      webhook = {
        ALLOWED_HOST_LIST = "loopback, private, ataraxiadev.com, *.ataraxiadev.com";
      };
    };
  };

  systemd.services.gitea-dump-clean = let
    older-than = "3"; # in days
  in rec {
    before = [ "gitea-dump.service" ];
    requiredBy = before;
    script = ''
      ${pkgs.findutils}/bin/find ${config.services.gitea.dump.backupDir} \
        -mindepth 1 -type f -mtime +${older-than} -delete
    '';
  };
}
