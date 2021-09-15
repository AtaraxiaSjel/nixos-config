{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard = {
    services.picom = {
      enable = true;
      backend = "glx";
      activeOpacity = "0.95";
      inactiveOpacity = "0.95";
      opacityRule = [
        # Disable opacity for fullscreen window
        "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_FULLSCREEN'"
        # Disable drawing underlying tabbed windows
        "0:_NET_WM_STATE@[0]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[1]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[2]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[3]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[4]:32a *= '_NET_WM_STATE_HIDDEN'"
        # Other rules
        "100:class_i ?= 'vivaldi-stable'"
        "100:class_g = 'mpv'"
        "100:class_g = 'explorer.exe'"
        "100:class_g = '.scrcpy-wrapped'"
        "90:class_g = 'URxvt' && focused"
        "70:class_g = 'URxvt' && !focused"
      ];
      blur = true;
      blurExclude = [
        "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
        "class_g = 'i3-frame'"
        "class_g = 'slop'"
      ];
      shadow = false;
      vSync = true;
      experimentalBackends = true;
      extraOptions = ''
        blur-method = "gaussian";
        blur-size = 10;
        blur-deviation = 5.0;
        # blur:
        # {
        #   method = "gaussian";
        #   size = 10;
        #   deviation = 5.0;
        # };
        unredir-if-possible = false;
      '';
    };
  };
}