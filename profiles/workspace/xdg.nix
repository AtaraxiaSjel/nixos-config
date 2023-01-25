{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    xdg.enable = true;
    xdg.userDirs.enable = true;
    xdg.systemDirs.data = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  };

  environment.sessionVariables = {
    DE = "generic";
  };

  persist.state.homeDirectories = [
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Videos"
  ];
}