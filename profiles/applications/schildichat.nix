{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.schildichat-desktop
  ];

  defaultApplications.matrix = {
    cmd = "${pkgs.schildichat-desktop}/bin/schildichat-desktop";
    desktop = "schildichat-desktop";
  };

  persist.state.homeDirectories = [
    ".config/SchildiChat"
  ];
}