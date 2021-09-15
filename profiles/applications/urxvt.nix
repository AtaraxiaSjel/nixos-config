{ config, lib, pkgs, ... }:
with config.lib.base16.theme;
with config.deviceSpecific;
let
  thm = config.lib.base16.theme;
in
{
  defaultApplications.term = lib.mkIf (isISO || isVM) {
    cmd = "${pkgs.rxvt-unicode}/bin/urxvt";
    desktop = "urxvt";
  };
  home-manager.users.alukard = lib.mkIf (isISO || isVM) {
    programs.urxvt = {
      enable = true;
      extraConfig = {
        "font" = "xft:${thm.fonts.powerline.family}:style=Regular:size=${thm.fontSizes.small.str}";
        "boldFont" = "xft:${thm.fonts.powerline.family}:style=Bold:size=${thm.fontSizes.small.str}";
        "italicFont" = "xft:${thm.fonts.powerline.family}:style=Italic:size=${thm.fontSizes.small.str}";
        "boldItalicfont" = "xft:${thm.fonts.powerline.family}:style=Bold Italic:size=${thm.fontSizes.small.str}";

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
    xresources.properties = with config.lib.base16.theme; {
      "*foreground" = "#${base05-hex}";
      "*background" = "#${base00-hex}";
      "*cursorColor" = "#${base05-hex}";
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
    };
  };
}