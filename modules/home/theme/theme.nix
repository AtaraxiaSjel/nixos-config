{ lib, pkgs, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    int
    package
    str
    submodule
    ;

  fontSubmodule = {
    options = {
      family = mkOption {
        type = str;
      };
      package = mkOption {
        type = package;
      };
    };
  };
in
{
  options.theme = {
    colors = mkOption {
      type = attrsOf str;
      default = { };
    };
    fonts = {
      sans = mkOption {
        type = submodule fontSubmodule;
        default = { };
      };
      serif = mkOption {
        type = submodule fontSubmodule;
        default = { };
      };
      mono = mkOption {
        type = submodule fontSubmodule;
        default = { };
      };
      emoji = mkOption {
        type = submodule fontSubmodule;
        default = { };
      };
      icons = mkOption {
        type = submodule fontSubmodule;
        default = { };
      };
      size = mkOption {
        type = submodule {
          options =
            let
              sizeOpt = mkOption {
                type = int;
              };
            in
            {
              big = sizeOpt;
              normal = sizeOpt;
              small = sizeOpt;
            };
        };
      };
    };
    icons = mkOption {
      type = (
        submodule {
          options = {
            name = mkOption {
              type = str;
            };
            package = mkOption {
              type = package;
            };
          };
        }
      );
      default = { };
    };
  };

  config = {
    theme = {
      colors = {
        color0 = "1e1e2e"; # base
        color1 = "181825"; # mantle
        color2 = "313244"; # surface0
        color3 = "45475a"; # surface1
        color4 = "585b70"; # surface2
        color5 = "cdd6f4"; # text
        color6 = "f5e0dc"; # rosewater
        color7 = "b4befe"; # lavender
        color8 = "f38ba8"; # red
        color9 = "fab387"; # peach
        color10 = "f9e2af"; # yellow
        color11 = "a6e3a1"; # green
        color12 = "94e2d5"; # teal
        color13 = "89b4fa"; # blue
        color14 = "cba6f7"; # mauve
        color15 = "f2cdcd"; # flamingo
      };
      fonts = {
        sans = {
          family = "Atkinson Hyperlegible Next";
          package = pkgs.atkinson-hyperlegible-next;
        };
        serif = {
          family = "Atkinson Hyperlegible Next";
          package = pkgs.atkinson-hyperlegible-next;
        };
        mono = {
          # family = "Atkinson Hyperlegible Mono";
          # package = pkgs.atkinson-hyperlegible-mono;
          family = "VictorMono Nerd Font Mono";
          package = pkgs.nerd-fonts.victor-mono;
        };
        emoji = {
          family = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
        icons = {
          # family = "Material Icons";
          # package = pkgs.material-icons;
          family = "Rose-Pine";
          package = pkgs.rosepine-gtk-icons;
        };
        size.big = 14;
        size.normal = 12;
        size.small = 11;
      };
      icons = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
