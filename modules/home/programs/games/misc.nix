{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.gaming;
in
{
  options.ataraxia.programs.gaming = {
    enable = mkEnableOption "Enable some games";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      faugus-launcher
      freesmlauncher
      osu-lazer-bin
      prefix-cleaner
      protonplus
      realrtcw
      stalker-gamma-cli
      vcmi
      voidrun
    ];

    persist.state.directories = [
      ".config/faugus-launcher"
      ".config/stalker-gamma"
      ".config/vcmi"
      ".config/WarThunder"
      ".local/share/faugus-launcher"
      ".local/share/ficsit"
      ".local/share/FreesmLauncher"
      ".local/share/osu"
      ".local/share/vcmi"
    ];
  };
}
