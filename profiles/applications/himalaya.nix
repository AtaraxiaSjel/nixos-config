{ config, pkgs, inputs, lib, system, ... }: {

  home-manager.users.alukard = {
    home.packages = [ pkgs.himalaya ];

    xdg.configFile."himalaya/config.toml".text = ''
      downloads-dir="/home/alukard/Downloads/mail"
      name="Dmitriy Kholkin"
      signature="Regards,"
      [ataraxiadev]
      default=true
      email="ataraxiadev@ataraxiadev.com"
      imap-host="mail.ataraxiadev.com"
      imap-login="ataraxiadev@ataraxiadev.com"
      imap-passwd-cmd="pass show email/ataraxiadev@ataraxiadev.com"
      imap-port=993
      smtp-host="mail.ataraxiadev.com"
      smtp-login="ataraxiadev@ataraxiadev.com"
      smtp-passwd-cmd="pass show email/ataraxiadev@ataraxiadev.com"
      smtp-port=465
    '';
  };
}