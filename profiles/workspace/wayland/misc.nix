{ config, lib, pkgs, ... }:
let
  inherit (config.deviceSpecific) isServer;
in {
  programs.ydotool.enable = true;

  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.wl-clipboard ];
    services.udiskie.enable = !isServer;
    services.gammastep = {
      enable = !isServer;
      provider = "manual";
      latitude = config.location.latitude;
      longitude = config.location.longitude;
      temperature.day = 6500;
      temperature.night = 3000;
      enableVerboseLogging = true;
      settings.general.adjustment-method = "wayland";
    };
    systemd.user.services.gammastep = {
      Install.WantedBy = lib.mkForce [];
    };
  };
}