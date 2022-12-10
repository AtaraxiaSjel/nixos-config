{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
with config.deviceSpecific;
{
  # defaultApplications.term = lib.mkIf (isDesktop) {
  #   cmd = "${pkgs.alacritty}/bin/alacritty";
  #   desktop = "alacritty";
  # };
  home-manager.users.${config.mainuser} = {
    programs.alacritty = {
      # enable = isDesktop;
      enable = false;
      settings = {
        font = {
          normal = {
            family = "${thm.fonts.mono.family}";
            style = "Regular";
          };
          bold = {
            family = "${thm.fonts.mono.family}";
            style = "Bold";
          };
          italic = {
            family = "${thm.fonts.mono.family}";
            style = "Italic";
          };
          bold_italic = {
            family = "${thm.fonts.mono.family}";
            style = "Bold Italic";
          };
          size = thm.fontSizes.small.int;
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
            text = "#${thm.base02-hex}";
            cursor = "#${thm.base00-hex}";
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