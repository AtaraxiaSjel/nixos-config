{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.zen-browser;
in
{
  options.ataraxia.programs.zen-browser = {
    enable = mkEnableOption "Enable Zen browser";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.zen-browser ];
    persist.state.directories = [ ".config/zen" ];
  };
}
