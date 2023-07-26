{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.element-desktop
  ];

  defaultApplications.matrix = {
    cmd = "${pkgs.element-desktop}/bin/element-desktop";
    desktop = "element-desktop";
  };

  persist.state.homeDirectories = [
    ".config/SchildiChat"
    ".config/Element"
  ];
}