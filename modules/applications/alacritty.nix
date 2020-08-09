{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
{
  home-manager.users.alukard = {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          # normal.family = "Roboto Mono for Powerline";
          # bold = { style = "Bold"; };
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
          size = 11;
        };

        window.padding = {
          x = 2;
          y = 2;
        };

        shell.program = "${pkgs.zsh}/bin/zsh";

        cursor.style = "Beam";

        colors = {
          primary = {
            background = "0x${thm.base00-hex}";
            foreground = "0x${thm.base05-hex}";
          };
          cursor = {
            text = "0x${thm.base00-hex}";
            cursor = "0x${thm.base05-hex}";
          };
          normal = {
            black = "0x${thm.base00-hex}";
            red = "0x${thm.base08-hex}";
            green = "0x${thm.base0B-hex}";
            yellow = "0x${thm.base0A-hex}";
            blue = "0x${thm.base0D-hex}";
            magenta = "0x${thm.base0E-hex}";
            cyan = "0x${thm.base0C-hex}";
            white = "0x${thm.base05-hex}";
          };
          bright = {
            black = "0x${thm.base03-hex}";
            red = "0x${thm.base09-hex}";
            green = "0x${thm.base01-hex}";
            yellow = "0x${thm.base02-hex}";
            blue = "0x${thm.base04-hex}";
            magenta = "0x${thm.base06-hex}";
            cyan = "0x${thm.base0F-hex}";
            white = "0x${thm.base07-hex}";
          };
          draw_bold_text_with_bright_colors = "false";
          # bright = {
          #   black = "0x${thm.base03-hex}";
          #   red = "0x${thm.base08-hex}";
          #   green = "0x${thm.base0B-hex}";
          #   yellow = "0x${thm.base0A-hex}";
          #   blue = "0x${thm.base0D-hex}";
          #   magenta = "0x${thm.base0E-hex}";
          #   cyan = "0x${thm.base0C-hex}";
          #   white = "0x${thm.base07-hex}";
          # };
          # indexed_colors = {
            # - { index: 16, color: '0xff8700' }
            # - { index: 17, color: '0xd65d0e' }
            # - { index: 18, color: '0x3a3a3a' }
            # - { index: 19, color: '0x4e4e4e' }
            # - { index: 20, color: '0x949494' }
            # - { index: 21, color: '0xd5c4a1' }
          # };

        };
      };
    };
  };
}