{ config, lib, pkgs, ... }:
{
  home-manager.users.${config.mainuser} = {
    services.picom = {
      enable = true;
      backend = "glx";
      activeOpacity = "0.98";
      inactiveOpacity = "0.98";
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
        "100:class_g = 'Minecraft* 1.17.1'"
        "100:class_g = 'steam_app_220200'"
        "100:class_g = 'Picture in picture'"
        "100:class_g = 'Pinta' && focused"
        "95:class_g = 'URxvt' && focused"
        "95:class_g = 'alacritty' && focused"
        "95:class_g = 'kitty' && focused"
        "85:class_g = 'URxvt' && !focused"
        "85:class_g = 'alacritty' && !focused"
        "85:class_g = 'kitty' && !focused"
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