{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.umu-launcher;
in
{
  options.ataraxia.programs.umu-launcher = {
    enable = mkEnableOption "Enable umu-launcher program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ umu-launcher ];
    persist.state.directories = [ ".local/share/umu" ];
  };
}
