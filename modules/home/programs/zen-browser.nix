{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.zen-browser;
  package = pkgs.zen-browser;
in
{
  options.ataraxia.programs.zen-browser = {
    enable = mkEnableOption "Enable Zen browser";
  };

  config = mkIf cfg.enable {
    defaultApplications.browser = {
      cmd = getExe package;
      desktop = "zen";
    };

    home.packages = [ package ];
    persist.state.directories = [ ".config/zen" ];
  };
}
