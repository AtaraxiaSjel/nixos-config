{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
with config.deviceSpecific;
{
  home-manager.users.alukard = {
    programs.alacritty = {
      enable = !isLaptop;
      settings = {
        font = {
          normal = {
            family = "${thm.powerlineFont}";
            style = "Regular";
          };
          bold = {
            family = "${thm.powerlineFont}";
            style = "Bold";
          };
          italic = {
            family = "${thm.powerlineFont}";
            style = "Italic";
          };
          bold_italic = {
            family = "${thm.powerlineFont}";
            style = "Bold Italic";
          };
          size = lib.toInt thm.smallFontSize;
        };

        window.padding = {
          x = 2;
          y = 2;
        };

        shell.program = "${pkgs.zsh}/bin/zsh";

        cursor.style = "Beam";

        colors = {
          primary = {
            background = "#${thm.base00-hex}";
            foreground = "#${thm.base05-hex}";
          };
          cursor = {
            text = "#${thm.base00-hex}";
            cursor = "#${thm.base05-hex}";
          };
          normal = {
            black = "#${thm.base00-hex}";
            red = "#${thm.base08-hex}";
            green = "#${thm.base0B-hex}";
            yellow = "#${thm.base0A-hex}";
            blue = "#${thm.base0D-hex}";
            magenta = "#${thm.base0E-hex}";
            cyan = "#${thm.base0C-hex}";
            white = "#${thm.base05-hex}";
          };
          bright = {
            black = "#${thm.base03-hex}";
            red = "#${thm.base09-hex}";
            green = "#${thm.base01-hex}";
            yellow = "#${thm.base02-hex}";
            blue = "#${thm.base04-hex}";
            magenta = "#${thm.base06-hex}";
            cyan = "#${thm.base0F-hex}";
            white = "#${thm.base07-hex}";
          };
          draw_bold_text_with_bright_colors = "false";
        };

        env = {
          WINIT_X11_SCALE_FACTOR = "1.0";
        };
      };
    };
  };
}