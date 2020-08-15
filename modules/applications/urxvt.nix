{ config, lib, pkgs, ... }:
with config.deviceSpecific;
with config.lib.base16.theme;
{
  home-manager.users.alukard = {
    programs.urxvt = {
      enable = isLaptop;
      extraConfig = {
        "font" = "xft:${powerlineFont}:style=Regular:size=${smallFontSize}";
        "boldFont" = "xft:${powerlineFont}:style=Bold:size=${smallFontSize}";
        "italicFont" = "xft:${powerlineFont}:style=Italic:size=${smallFontSize}";
        "boldItalicfont" = "xft:${powerlineFont}:style=Bold Italic:size=${smallFontSize}";

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

        "foreground" = "#${base05-hex}";
        "background" = "#${base00-hex}";
        "cursorColor" = "#${base05-hex}";
        "color0" = "#${base00-hex}";
        "color1" = "#${base08-hex}";
        "color2" = "#${base0B-hex}";
        "color3" = "#${base0A-hex}";
        "color4" = "#${base0D-hex}";
        "color5" = "#${base0E-hex}";
        "color6" = "#${base0C-hex}";
        "color7" = "#${base05-hex}";
        "color8" = "#${base03-hex}";
        "color9" = "#${base08-hex}";
        "color10" = "#${base0B-hex}";
        "color11" = "#${base0A-hex}";
        "color12" = "#${base0D-hex}";
        "color13" = "#${base0E-hex}";
        "color14" = "#${base0C-hex}";
        "color15" = "#${base07-hex}";
        "color16" = "#${base09-hex}";
        "color17" = "#${base0F-hex}";
        "color18" = "#${base01-hex}";
        "color19" = "#${base02-hex}";
        "color20" = "#${base04-hex}";
        "color21" = "#${base06-hex}";
      };
    };
  };
}