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
      dotnetCorePackages.dotnet_9.runtime
      faugus-launcher
      freesmlauncher
      osu-lazer-bin
      protonplus
      stalker-gamma-cli
      vcmi
      voidrun
    ];

    persist.state.directories = [
      ".config/faugus-launcher"
      ".config/SLSsteam"
      ".config/stalker-gamma"
      ".config/Tachibana Labs"
      ".config/vcmi"
      ".config/WarThunder"
      ".local/share/ACCELA"
      ".local/share/faugus-launcher"
      ".local/share/ficsit"
      ".local/share/FreesmLauncher"
      ".local/share/osu"
      ".local/share/SLSsteam"
      ".local/share/SteaMidra"
      ".local/share/vcmi"
    ];
  };
}
