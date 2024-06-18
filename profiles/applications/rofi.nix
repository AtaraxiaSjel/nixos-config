{ pkgs, config, ... }:
let
  thm = config.lib.base16.theme;
  themeFile = config.lib.base16.templateFile { name = "rofi"; };
in
{
  defaultApplications.dmenu = {
    cmd = "${pkgs.rofi-wayland}/bin/rofi -show run";
    desktop = "rofi";
  };

  home-manager.users.${config.mainuser} = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "${thm.fonts.mono.family} ${thm.fontSizes.header.str}";
      terminal = config.defaultApplications.term.cmd;
      # theme = "${themeFile}";
    };
  };
}