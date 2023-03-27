{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    xdg.enable = true;
    xdg.userDirs.enable = true;
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