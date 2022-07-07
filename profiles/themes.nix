{ config, lib, pkgs, inputs, ... }: {

  config.themes.base16 = with config.deviceSpecific.devInfo; {
    enable = true;
    customScheme = {
      enable = true;
      path = "${inputs.base16-tokyonight-scheme}/tokyonight-night.yaml";
    };
    # scheme = "gruvbox";
    # variant = "gruvbox-dark-medium";
    extraParams = {
      fonts = {
        main = {
          family = "IBM Plex Sans";
          size = 12;
        };
        serif = {
          family = "IBM Plex Serif";
          size = 12;
        };
        mono = {
          family = "IBM Plex Mono";
          size = 12;
        };
        powerline = {
          family = "IBM Plex Mono for Powerline";
          size = 12;
        };
        icon = {
          family = "Font Awesome 5 Free";
          size = 12;
        };
        iconFallback = {
          family = "Material Icons";
          size = 12;
        };
      };
      fontSizes = {
        normal = {
          str = "12";
          int = 12;
          float = 12.0;
        };
        header = {
          str = "14";
          int = 14;
          float = 14.0;
        };
        small = {
          str = "11";
          int = 11;
          float = 11.0;
        };
        micro = {
          str = "10";
          int = 10;
          float = 10.0;
        };
        minimal = {
          str = "8";
          int = 8;
          float = 8.0;
        };
      };

      # iconTheme = "Papirus-Dark";
      # iconPackage = pkgs.papirus-icon-theme;
      iconTheme = "tokyonight_dark";
      iconPackage = pkgs.tokyonight-icon-theme;

      cursorPackage = pkgs.bibata-cursors-tokyonight;
      # cursorPackage = pkgs.bibata-cursors;
      cursorSize = 16;
    };
  };
}
