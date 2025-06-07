{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.spotify;
in
{
  options.ataraxia.programs.spotify = {
    enable = mkEnableOption "Enable spotify program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      spotifywm
    ];

    defaultApplications.spotify = {
      cmd = getExe pkgs.spotifywm;
      desktop = "spotify";
    };

    startupApplications = [
      config.defaultApplications.spotify.cmd
    ];

    persist.state.directories = [
      ".config/spotify"
    ];
  };
}
