{ config, lib, pkgs, ... }:
with config.lib.base16.theme;
let
  thm = config.lib.base16.theme;
in
{
  home-manager.users.alukard = {
    programs.urxvt = {
      enable = config.deviceSpecific.isLaptop;
      extraConfig = {
        "font" = "xft:${thm.powerlineFont}:style=Regular:size=${thm.smallFontSize}";
        "boldFont" = "xft:${thm.powerlineFont}:style=Bold:size=${thm.smallFontSize}";
        "italicFont" = "xft:${thm.powerlineFont}:style=Italic:size=${thm.smallFontSize}";
        "boldItalicfont" = "xft:${thm.powerlineFont}:style=Bold Italic:size=${thm.smallFontSize}";

        "letterSpace" = "0";
        "lineSpace" = "0";
        "geometry" = "92x24";
        "internalBorder" = "24";
        "cursorBlink" = "true";
        "cursorUnderline" = "false";
        "saveline" = "2048";
        "scrollBar" = "false";
        "scrollBar_right" = "false";
        "urgentOnBell" = "true";
        "depth" = "24";
        "iso14755" = "false";

        "keysym.Shift-Up" = "command:\\033]720;1\\007";
        "keysym.Shift-Down" = "command:\\033]721;1\\007";
        "keysym.Control-Up" = "\\033[1;5A";
        "keysym.Control-Down" = "\\033[1;5B";
        "keysym.Control-Right" = "\\033[1;5C";
        "keysym.Control-Left" = "\\033[1;5D";

        "foreground" = "#${thm.base05-hex}";
        "background" = "#${thm.base00-hex}";
        "cursorColor" = "#${thm.base05-hex}";
        "color0" = "#${thm.base00-hex}";
        "color1" = "#${thm.base08-hex}";
        "color2" = "#${thm.base0B-hex}";
        "color3" = "#${thm.base0A-hex}";
        "color4" = "#${thm.base0D-hex}";
        "color5" = "#${thm.base0E-hex}";
        "color6" = "#${thm.base0C-hex}";
        "color7" = "#${thm.base05-hex}";
        "color8" = "#${thm.base03-hex}";
        "color9" = "#${thm.base08-hex}";
        "color10" = "#${thm.base0B-hex}";
        "color11" = "#${thm.base0A-hex}";
        "color12" = "#${thm.base0D-hex}";
        "color13" = "#${thm.base0E-hex}";
        "color14" = "#${thm.base0C-hex}";
        "color15" = "#${thm.base07-hex}";
        "color16" = "#${thm.base09-hex}";
        "color17" = "#${thm.base0F-hex}";
        "color18" = "#${thm.base01-hex}";
        "color19" = "#${thm.base02-hex}";
        "color20" = "#${thm.base04-hex}";
        "color21" = "#${thm.base06-hex}";
      };
    };
  };
}