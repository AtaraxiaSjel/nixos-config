{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
with config.deviceSpecific;
{
  home-manager.users.alukard = {
    programs.kitty = {
      enable = isLaptop;
      font.name = "${thm.powerlineFont} ${thm.smallFontSize}";
      # keybindings = ''
      # '';
      settings = {
        foreground = "#${base05-hex}";
        background = "#${base00-hex}";
        selection_background = "#${base05-hex}";
        selection_foreground = "#${base00-hex}";
        url_color = "#${base04-hex}";
        active_border_color = "#${base03-hex}";
        inactive_border_color = "#${base01-hex}";
        active_tab_background = "#${base00-hex}";
        active_tab_foreground = "#${base05-hex}";
        inactive_tab_background = "#${base01-hex}";
        inactive_tab_foreground = "#${base04-hex}";
        tab_bar_background = "#${base01-hex}";
        cursor = "#${base05-hex}";
        color0 = "#${base00-hex}";
        color1 = "#${base08-hex}";
        color2 = "#${base0B-hex}";
        color3 = "#${base0A-hex}";
        color4 = "#${base0D-hex}";
        color5 = "#${base0E-hex}";
        color6 = "#${base0C-hex}";
        color7 = "#${base05-hex}";
        color8 = "#${base03-hex}";
        color9 = "#${base08-hex}";
        color10 = "#${base0B-hex}";
        color11 = "#${base0A-hex}";
        color12 = "#${base0D-hex}";
        color13 = "#${base0E-hex}";
        color14 = "#${base0C-hex}";
        color15 = "#${base07-hex}";
        color16 = "#${base09-hex}";
        color17 = "#${base0F-hex}";
        color18 = "#${base01-hex}";
        color19 = "#${base02-hex}";
        color20 = "#${base04-hex}";
        color21 = "#${base06-hex}";
      };
    };
  };
}