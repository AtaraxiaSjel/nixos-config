{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.schildichat-desktop-wayland
  ];

  defaultApplications.matrix = {
    cmd = "${pkgs.schildichat-desktop-wayland}/bin/schildichat-desktop";
    desktop = "schildichat-desktop";
  };

  persist.state.homeDirectories = [
    ".config/SchildiChat"
  ];
}