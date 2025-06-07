{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  inherit (config.theme) fonts;
  cfg = config.ataraxia.programs.rofi;
in
{
  options.ataraxia.programs.rofi = {
    enable = mkEnableOption "Enable rofi program";
  };

  config = mkIf cfg.enable {
    defaultApplications.dmenu = {
      cmd = "${getExe config.programs.rofi.package} -show run";
      desktop = "rofi";
    };

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "${fonts.mono.family} ${toString fonts.size.big}";
      terminal = config.defaultApplications.term.cmd;
      # theme = "${themeFile}";
    };
  };
}
