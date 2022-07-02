{ config, lib, ... }:
with config.deviceSpecific; {
  home-manager.users.alukard = {
    programs.gpg = {
      enable = true;
      homedir = "${config.home-manager.users.alukard.xdg.dataHome}/gnupg";
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
          "GNUPGHOME=${config.home-manager.users.alukard.xdg.dataHome}/gnupg"
        ];
      };
    };
  };
}