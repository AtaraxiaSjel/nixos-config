{ config, ... }:
{
  home-manager.users.alukard = {
    programs.gpg = {
      enable = true;
      homedir = "${config.home-manager.users.alukard.xdg.dataHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gnome3";
      sshKeys = [
        # "E6A6377C3D0827C36428A290199FDB3B91414AFE"
        "7A7130ABF128CC2C32B3D6AD27515056B0193CE1"
      ];
    };
  };
}