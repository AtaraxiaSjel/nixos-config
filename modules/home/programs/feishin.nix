{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.feishin;
in
{
  options.ataraxia.programs.feishin = {
    enable = mkEnableOption "Enable feishin program";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.feishin ];
    persist.state.directories = [ ".config/feishin" ];
  };
}
