{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.cursor;

  inherit (config.theme) cursor;
in
{
  options.ataraxia.defaults.cursor = {
    enable = mkEnableOption "Setup default cursor theme";
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      inherit (cursor) name package size;
      enable = true;
      dotIcons.enable = true;
      gtk.enable = true;
    };

    startupApplications = [
      "hyprctl setcursor '${cursor.name}-hypr' ${toString cursor.size}"
    ];
  };
}
