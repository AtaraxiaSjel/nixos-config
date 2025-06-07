{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.telegram;
in
{
  options.ataraxia.programs.telegram = {
    enable = mkEnableOption "Enable telegram program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      telegram-desktop
    ];

    defaultApplications.messenger = {
      cmd = getExe pkgs.telegram-desktop;
      desktop = "telegram-desktop";
    };

    startupApplications = with config.defaultApplications; [
      messenger.cmd
    ];

    persist.state.directories = [
      ".local/share/TelegramDesktop"
    ];
  };
}
