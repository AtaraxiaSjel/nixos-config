{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
{
  home-manager.users.alukard = {
    programs.kitty = {
      enable = config.deviceSpecific.isLaptop;
      font.name = "${thm.powerlineFont} ${thm.smallFontSize}";
      # keybindings = ''
      # '';
      settings = {
        foreground = "#${thm.base05-hex}";
        background = "#${thm.base00-hex}";
        selection_background = "#${thm.base05-hex}";
        selection_foreground = "#${thm.base00-hex}";
        url_color = "#${thm.base04-hex}";
        active_border_color = "#${thm.base03-hex}";
        inactive_border_color = "#${thm.base01-hex}";
        active_tab_background = "#${thm.base00-hex}";
        active_tab_foreground = "#${thm.base05-hex}";
        inactive_tab_background = "#${thm.base01-hex}";
        inactive_tab_foreground = "#${thm.base04-hex}";
        tab_bar_background = "#${thm.base01-hex}";
        cursor = "#${thm.base05-hex}";
        color0 = "#${thm.base00-hex}";
        color1 = "#${thm.base08-hex}";
        color2 = "#${thm.base0B-hex}";
        color3 = "#${thm.base0A-hex}";
        color4 = "#${thm.base0D-hex}";
        color5 = "#${thm.base0E-hex}";
        color6 = "#${thm.base0C-hex}";
        color7 = "#${thm.base05-hex}";
        color8 = "#${thm.base03-hex}";
        color9 = "#${thm.base08-hex}";
        color10 = "#${thm.base0B-hex}";
        color11 = "#${thm.base0A-hex}";
        color12 = "#${thm.base0D-hex}";
        color13 = "#${thm.base0E-hex}";
        color14 = "#${thm.base0C-hex}";
        color15 = "#${thm.base07-hex}";
        color16 = "#${thm.base09-hex}";
        color17 = "#${thm.base0F-hex}";
        color18 = "#${thm.base01-hex}";
        color19 = "#${thm.base02-hex}";
        color20 = "#${thm.base04-hex}";
        color21 = "#${thm.base06-hex}";
        enable_audio_bell = false;
      };
    };
  };
}