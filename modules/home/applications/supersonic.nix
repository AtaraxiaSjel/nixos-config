{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.supersonic;
in
{
  options.ataraxia.programs.supersonic = {
    enable = mkEnableOption "Enable supersonic program";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.supersonic-wayland ];
    persist.state.directories = [ ".config/supersonic" ];
  };
}
