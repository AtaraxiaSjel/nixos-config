{ config, lib, pkgs, ... }: {
  home-manager.users.${config.mainuser}.home.packages = with pkgs; [
    spotifywm
  ];
  
  startupApplications = [
    "${pkgs.spotifywm}/bin/spotify"
  ];
  
  persist.state.homeDirectories = [
    ".config/spotify"
  ];
}
