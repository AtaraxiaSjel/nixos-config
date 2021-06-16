{ pkgs, config, lib, ... }:
let
  thm = config.lib.base16.theme;
  themeFile = config.lib.base16.templateFile { name = "rofi"; };
in
{
  defaultApplications.dmenu = {
    cmd = "${pkgs.rofi}/bin/rofi -show run";
    desktop = "rofi";
  };

  home-manager.users.alukard = {
    programs.rofi = {
      enable = true;
      font = "${thm.fontMono} ${thm.headerFontSize}";
      terminal = config.defaultApplications.term.cmd;
      theme = "${themeFile}";
    };
  };
}