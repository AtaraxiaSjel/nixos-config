{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.lutris;
in
{
  options.ataraxia.programs.lutris = {
    enable = mkEnableOption "Enable lutris program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lutris
      wine
    ];

    persist.state.directories = [ ".local/share/lutris" ];
  };
}
