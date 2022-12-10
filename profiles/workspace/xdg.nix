{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    xdg.enable = true;
    xdg.userDirs.enable = true;

    home.sessionVariables.XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  };

  environment.sessionVariables = {
    # XDG_CURRENT_DESKTOP = "X-Generic";
    DE = "generic";
  };
}