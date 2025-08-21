{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.vesktop;
in
{
  options.ataraxia.programs.vesktop = {
    enable = mkEnableOption "Enable vesktop program";
  };

  config = mkIf cfg.enable {
    programs.vesktop.enable = true;
    programs.vesktop.settings = {
      # appBadge = false;
      # arRPC = true;
      # checkUpdates = false;
      # customTitleBar = false;
      # disableMinSize = true;
      minimizeToTray = true;
      # tray = false;
      # splashBackground = "#000000";
      # splashColor = "#ffffff";
      # splashTheming = true;
      # staticTitle = true;
      hardwareAcceleration = true;
      discordBranch = "canary";
    };
    # programs.vesktop.vencord.settings = {};
    # programs.vesktop.vencord.themes = {};
    # programs.vesktop.vencord.useSystem = false;

    persist.state.directories = [ ".config/vesktop" ];
  };
}
