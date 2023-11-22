{ config, pkgs, lib, ... }: {

  home-manager.users.${config.mainuser} = {
    home.packages = [
      # pkgs.himalaya
      pkgs.gnome.geary
    ];

    # xdg.configFile."himalaya/config.toml".text = ''
    #   downloads-dir = "/home/${config.mainuser}/Downloads/mail"
    #   name = "Dmitriy Kholkin"
    #   signature = "Regards,"
    #   # email-reading-verify-cmd
    #   # email-reading-decrypt-cmd
    #   # email-writing-sign-cmd
    #   # email-writing-encrypt-cmd
    #   # notify-cmd
    #   # notify-query
    #   # sync

    #   [ataraxiadev]
    #   default = true
    #   email = "ataraxiadev@ataraxiadev.com"

    #   backend = "imap"
    #   imap-host = "mail.ataraxiadev.com"
    #   imap-port = 993
    #   imap-login = "ataraxiadev@ataraxiadev.com"
    #   imap-passwd-cmd = "${pkgs.pass}/bin/pass show email/ataraxiadev@ataraxiadev.com"
    #   imap-ssl = true
    #   imap-starttls = false
    #   imap-insecure = false

    #   sender = "smtp"
    #   smtp-host = "mail.ataraxiadev.com"
    #   smtp-port = 465
    #   smtp-login = "ataraxiadev@ataraxiadev.com"
    #   smtp-passwd-cmd = "${pkgs.pass}/bin/pass show email/ataraxiadev@ataraxiadev.com"
    #   smtp-ssl = true
    #   smtp-starttls = false
    #   smtp-insecure = false
    # '';
  };

  # systemd.user.services.himalaya-notify = {
  #   description = "Himalaya new messages notifier";
  #   after = [ "network.target" ];
  #   wantedBy = [ "default.target" ];

  #   script = "himalaya notify";
  #   environment = {
  #     PASSWORD_STORE_DIR = config.secretsConfig.password-store;
  #     GNUPGHOME = config.secretsConfig.gnupgHome;
  #   };
  #   # script = "echo $(pass show email/ataraxiadev@ataraxiadev.com) || echo lol";
  #   path = with pkgs; [ himalaya libnotify pass gnupg ];
  #   serviceConfig = {
  #     Restart = lib.mkForce "no";
  #     # Restart = "always";
  #     RestartSec = 10;
  #     # Type = "oneshot";
  #   };
  # };

  defaultApplications.mail = {
    cmd = "${pkgs.gnome.geary}/bin/geary";
    desktop = "geary";
  };

  startupApplications = [
    config.defaultApplications.mail.cmd
  ];

  persist.state.homeDirectories = [
    ".config/himalaya"
    ".config/geary"
    ".local/share/geary"
  ];
}