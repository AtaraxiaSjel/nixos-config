{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.zen-browser;
  package = pkgs.zen-browser;
in
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  options.ataraxia.programs.zen-browser = {
    enable = mkEnableOption "Enable Zen browser";
  };

  config = mkIf cfg.enable {
    defaultApplications.browser = {
      cmd = getExe package;
      desktop = "zen-beta.desktop";
    };

    programs.zen-browser = {
      enable = true;
      # setAsDefaultBrowser = true;
      profiles.ataraxia.presets.betterfox.enable = true;
    };

    # home.packages = [ package ];
    persist.state.directories = [ ".config/zen" ];
  };
}
