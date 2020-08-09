{ pkgs, config, lib, ... }:
let
  thm = config.lib.base16.theme;
  themeFile = config.lib.base16.templateFile { name = "rofi"; };
in
{
  home-manager.users.alukard = {
    programs.rofi = {
      enable = true;
      font = "${thm.fontMono} ${thm.headerSize}";
      terminal = config.defaultApplications.term.cmd;
      theme = "${themeFile}";
    };
  };
}