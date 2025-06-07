{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.ataraxia.wayland;
in
{
  options.ataraxia.wayland = {
    enable = mkEnableOption "Enable wayland with compositor and other components";
  };

  config = mkIf cfg.enable {
    ataraxia.wayland.hyprland.enable = mkDefault true;
    ataraxia.wayland.waybar.enable = mkDefault true;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
