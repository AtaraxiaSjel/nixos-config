{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard = {
    services.picom = {
      enable = true;
      activeOpacity = "0.95";
      inactiveOpacity = "0.95";
      opacityRule = [
        "100:class_i ?= 'vivaldi-stable'"
        "100:class_g = 'mpv'"
        "90:class_g = 'URxvt' && focused"
        "70:class_g = 'URxvt' && !focused"
      ];
      blur = true;
      shadow = false;
      vSync = true;
      experimentalBackends = true;
      extraOptions = ''
        blur:
        {
          method = "gaussian";
          size = 10;
          deviation = 5.0;
        };
      '';
    };
  };
}