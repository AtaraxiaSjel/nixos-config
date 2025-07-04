{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf unique;
  cfg = config.ataraxia.defaults.fonts;

  inherit (config.theme) fonts;
in
{
  options.ataraxia.defaults.fonts = {
    enable = mkEnableOption "Setup default fonts";
  };

  config = mkIf cfg.enable {
    home.packages = unique [
      fonts.sans.package
      fonts.serif.package
      fonts.mono.package
      fonts.emoji.package
      fonts.icons.package
      fonts.cyrillic.package
    ];

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ fonts.emoji.family ];
          monospace = [ fonts.mono.family ];
          sansSerif = [
            fonts.sans.family
            fonts.cyrillic.family
          ];
          serif = [
            fonts.serif.family
            fonts.cyrillic.family
          ];
        };
      };
    };
  };
}
