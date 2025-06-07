{ config, lib, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  inherit (config.theme) colors fonts icons;

  cfg = config.ataraxia.wayland.mako;
in
{
  options.ataraxia.wayland.mako = {
    enable = mkEnableOption "Enable mako";
  };

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 10000;
        font = "${fonts.sans.family} ${toString fonts.size.normal}";
        height = 80;
        icon-path = "${icons.package}/share/icons/${icons.name}";
        layer = "overlay";
        max-icon-size = 24;
        max-visible = 10;
        width = 500;
        backgroundColor = mkDefault "#${colors.color0}AA";
        textColor = mkDefault "#${colors.color5}";
        borderColor = mkDefault "#${colors.color13}AA";
        progressColor = mkDefault "over #${colors.color11}";
      };
    };
  };
}
