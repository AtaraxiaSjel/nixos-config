{ config, pkgs, inputs, lib, system, ... }: {
  secrets.email = {
    owner = "alukard:users";
    services = [ ];
    encrypted = "${config.environment.sessionVariables.PASSWORD_STORE_DIR}/email/ataraxiadev@ataraxiadev.com.gpg";
  };

  home-manager.users.alukard = {
    home.packages = [ pkgs.himalaya ];
    # home.packages = [ inputs.himalaya.defaultPackage.${system} ];

    xdg.configFile."himalaya/config.toml".text = ''
      downloads-dir="/home/alukard/Downloads/mail"
      name="Dmitriy Kholkin"
      signature="Regards,"
      [ataraxiadev]
      default=true
      email="ataraxiadev@ataraxiadev.com"
      imap-host="ataraxiadev.com"
      imap-login="ataraxiadev@ataraxiadev.com"
      imap-passwd-cmd="pass show /var/secrets/email"
      imap-port=993
      smtp-host="ataraxiadev.com"
      smtp-login="ataraxiadev@ataraxiadev.com"
      smtp-passwd-cmd="pass show /var/secrets/email"
      smtp-port=465
    '';
  };
}