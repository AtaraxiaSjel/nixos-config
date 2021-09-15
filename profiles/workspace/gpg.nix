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
      pinentryFlavor = "gtk2";
      sshKeys = [
        "7A7130ABF128CC2C32B3D6AD27515056B0193CE1"
      ];
    };
  };
}