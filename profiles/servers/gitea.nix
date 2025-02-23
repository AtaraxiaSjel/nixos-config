{ pkgs, config, lib, inputs, ... }:
let
  gitea-user = config.services.gitea.user;
  gitea-group = "gitea";
  # runner-user = "gitea-runner";
  # runner-group = "root";
  gitea-secret = {
    sopsFile = inputs.self.secretsDir + /gitea.yaml;
    owner = gitea-user;
    restartUnits = [ "gitea.service" ];
  };
  # runner-secret = services: {
  #   sopsFile = inputs.self.secretsDir + /home-hypervisor/gitea.yaml;
  #   owner = runner-user;
  #   restartUnits = services;
  # };
in {
  sops.secrets.gitea = gitea-secret;
  sops.secrets.gitea-mailer = gitea-secret;
  # sops.secrets.gitea-runner-hypervisor = runner-secret [ "gitea-runner-hypervisor.service" ];

  persist.state.directories = [
    # "/var/lib/gitea-runner"
    # { directory = "/var/lib/gitea-runner"; user = runner-user; group = runner-group; }
  ] ++ lib.optionals (config.deviceSpecific.devInfo.fileSystem != "zfs") [
    { directory = "/srv/gitea"; user = gitea-user; group = gitea-group; }
  ];

  backups.postgresql.gitea = {};

  # TODO: backups! gitea.dump setting
  services.gitea = {
    enable = true;
    package = pkgs.gitea;
    appName = "AtaraxiaDev's Gitea Instance";
    database = {
      type = "postgres";
      passwordFile = config.sops.secrets.gitea.path;
    };
    dump = {
      enable = true;
      backupDir = "/srv/gitea/dump";
      interval = "06:00";
      type = "tar.zst";
    };
    lfs.enable = true;
    stateDir = "/srv/gitea/data";
    mailerPasswordFile = config.sops.secrets.gitea-mailer.path;
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

  # users.users.${runner-user} = {
  #   isSystemUser = true;
  #   group = runner-group;
  # };
  # services.gitea-actions-runner.instances.hypervisor = {
  #   enable = true;
  #   name = "hypervisor";
  #   url = config.services.gitea.settings.server.ROOT_URL;
  #   tokenFile = config.sops.secrets.gitea-runner-hypervisor.path;
  #   labels = [
  #     "native:host"
  #     "debian-latest:docker://debian:12-slim"
  #   ];
  #   hostPackages = with pkgs; [
  #     bash
  #     curl
  #     gawk
  #     gitMinimal
  #     gnused
  #     wget
  #   ];
  #   # TODO: fix cache server
  #   # settings = {};
  # };
  # systemd.services.gitea-runner-hypervisor = {
  #   serviceConfig.DynamicUser = lib.mkForce false;
  #   serviceConfig.User = lib.mkForce runner-user;
  #   serviceConfig.Group = lib.mkForce runner-group;
  # };
}
