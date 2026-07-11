{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.jellyfin-mpv-shim;
in
{
  options.ataraxia.programs.jellyfin-mpv-shim = {
    enable = mkEnableOption "Enable jellyfin-mpv-shim program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ jellyfin-mpv-shim ];

    startupApplications = [
      (getExe pkgs.jellyfin-mpv-shim)
    ];

    persist.state.directories = [
      ".config/jellyfin-mpv-shim"
    ];
  };
}
