{ config, lib, ... }:
with config.deviceSpecific; {
  home-manager.users.${config.mainuser} = {
    programs.gpg = {
      enable = true;
      homedir = config.secretsConfig.gnupgHome;
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = if !isServer then "gnome3" else "curses";
      sshKeys = [
        "7A7130ABF128CC2C32B3D6AD27515056B0193CE1"
        "E6A6377C3D0827C36428A290199FDB3B91414AFE"
      ];
    };

    systemd.user.services.gpg-agent = {
      Service = {
        Environment = lib.mkForce [
          "GPG_TTY=/dev/tty1"
          "DISPLAY=:0"
          "GNUPGHOME=${config.secretsConfig.gnupgHome}"
        ];
      };
    };
  };

  # persist.state.homeDirectories = [{
  #   directory = config.secretsConfig.gnupgHome;
  #   method = "symlink";
  # }];
  persist.state.homeDirectories = let
    gnupgHome-relative = lib.removePrefix
      config.home-manager.users.${config.mainuser}.home.homeDirectory
        config.secretsConfig.gnupgHome;
  in [ gnupgHome-relative ];
}