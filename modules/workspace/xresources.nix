
{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard = {
    xresources.properties = with config.lib.base16.theme; {
      "*background" = "#${base00-hex}";
      "*foreground" = "#${base05-hex}";
      "*color0" = "#${base00-hex}";
      "*color1" = "#${base08-hex}";
      "*color2" = "#${base0B-hex}";
      "*color3" = "#${base0A-hex}";
      "*color4" = "#${base0D-hex}";
      "*color5" = "#${base0E-hex}";
      "*color6" = "#${base0C-hex}";
      "*color7" = "#${base05-hex}";
      "*color8" = "#${base03-hex}";
      "*color9" = "#${base09-hex}";
      "*color10" = "#${base01-hex}";
      "*color11" = "#${base02-hex}";
      "*color12" = "#${base04-hex}";
      "*color13" = "#${base06-hex}";
      "*color14" = "#${base0F-hex}";
      "*color15" = "#${base07-hex}";
      "*cursorColor" = "#${base05-hex}";

      "URxvt.font" = "xft:${powerlineFont}:style=Regular:size=11";
      "URxvt.boldFont" = "xft:${powerlineFont}:style=Bold:size=11";
      "URxvt.italicFont" = "xft:${powerlineFont}:style=Italic:size=11";
      "URxvt.boldItalicfont" = "xft:${powerlineFont}:style=Bold Italic:size=11";

      "URxvt.letterSpace" = "0";
      "URxvt.lineSpace" = "0";
      "URxvt.geometry" = "92x24";
      "URxvt.internalBorder" = "24";
      "URxvt.cursorBlink" = "true";
      "URxvt.cursorUnderline" = "false";
      "URxvt.saveline" = "2048";
      "URxvt.scrollBar" = "false";
      "URxvt.scrollBar_right" = "false";
      "URxvt.urgentOnBell" = "true";
      "URxvt.depth" = "24";
      "URxvt.iso14755" = "false";

      "URxvt.keysym.Shift-Up" = "command:\\033]720;1\\007";
      "URxvt.keysym.Shift-Down" = "command:\\033]721;1\\007";
      "URxvt.keysym.Control-Up" = "\\033[1;5A";
      "URxvt.keysym.Control-Down" = "\\033[1;5B";
      "URxvt.keysym.Control-Right" = "\\033[1;5C";
      "URxvt.keysym.Control-Left" = "\\033[1;5D";
    };
  };
}