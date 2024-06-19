{ config, pkgs, ... }: {
  home-manager.users.${config.mainuser}.home.packages = with pkgs; [
    spotifywm
  ];

  defaultApplications.spotify = {
    cmd = "${pkgs.spotify}/bin/spotify";
    desktop = "spotify";
  };

  startupApplications = [
    "${pkgs.spotifywm}/bin/spotify"
  ];

  persist.state.homeDirectories = [
    ".config/spotify"
  ];
}
