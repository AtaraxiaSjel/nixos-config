{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.gammastep;
in
{
  options.ataraxia.programs.gammastep = {
    enable = mkEnableOption "Enable gammastep program";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gammastep ];
    services.gammastep = {
      enable = true;
      dawnTime = "6:00-7:40";
      duskTime = "21:00-22:40";
      temperature.day = 6500;
      temperature.night = 5000;
      settings = {
        general = {
          adjustment-method = "wayland";
          brightness-day = "1.0";
          brightness-night = "0.9";
        };
      };
    };
  };
}
