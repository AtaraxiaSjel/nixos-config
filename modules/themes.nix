{ config, lib, pkgs, inputs, ... }: {

  config.themes.base16 = with config.deviceSpecific.devInfo; {
    enable = true;
    # customScheme = {
    #   enable = true;
    #   path = "${inputs.base16-horizon-scheme}/horizon-dark.yaml";
    # };
    scheme = "gruvbox";
    variant = "gruvbox-dark-medium";
    extraParams = {
      font = "IBM Plex Sans";
      fontMono = "IBM Plex Mono";
      fontSerif = "IBM Plex Serif";
      powerlineFont = "IBM Plex Mono for Powerline";

      fallbackFont = "Roboto";
      fallbackFontMono = "Roboto Mono";
      fallbackFontSerif = "Roboto Slab";

      iconFont = "Font Awesome 5 Free";
      fallbackIcon = "Material Icons";
      iconTheme = "Papirus-Dark";
      iconPackage = pkgs.papirus-icon-theme;

      normalFontSize = "12";
      headerFontSize = "14";
      smallFontSize = "11";
      microFontSize = "10";
      minimalFontSize = "8";

      cursorPackage = pkgs.bibata-cursors;
      cursorSize = 16;
    };
  };
}
