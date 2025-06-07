{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (builtins) mapAttrs;
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    optionalString
    ;
  inherit (config.theme) colors;
  cfg = config.ataraxia.wayland.hyprland;

  apps = config.defaultApplications;
  useNixosHyprland = osConfig != null && osConfig.programs.hyprland.enable;
  useWithUWSM = osConfig != null && osConfig.programs.hyprland.withUWSM;
  execApp = optionalString useWithUWSM "uwsm app --";
in
{
  options.ataraxia.wayland.hyprland = {
    enable = mkEnableOption "Enable hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cliphist
      grim
      libnotify
      mpris-ctl
      pamixer
      pavucontrol
      slurp
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = mkIf useNixosHyprland null;
      portalPackage = mkIf useNixosHyprland null;
      systemd.enable = !useWithUWSM;
      systemd.variables = [ "--all" ];
      xwayland.enable = true;
      settings = {
        animations.enabled = true;
        # fix gamescope issue: https://github.com/NixOS/nixpkgs/issues/351516
        debug.full_cm_proto = true;
        decoration = {
          active_opacity = 0.95;
          blur = {
            enabled = true;
            ignore_opacity = true;
            passes = 3;
            size = 2;
          };
          fullscreen_opacity = 1.0;
          inactive_opacity = 0.85;
          rounding = 0;
          shadow = {
            enabled = true;
            color = "0xAA${colors.color8}";
            ignore_window = true;
            offset = "0 0";
            range = 6;
          };
        };
        ecosystem.no_update_news = true;
        experimental.xx_color_management_v4 = true;
        general = {
          border_size = 1;
          #col.active_border = "0xAA${colors.color8}";
          #col.inactive_border = "0xAA${colors.color10}";
          #col.nogroup_border = "0xCC${colors.color10}";
          #col.nogroup_border_active = "0xAA${colors.color8}";
          gaps_in = 6;
          gaps_out = 12;
          no_border_on_floating = false;
        };
        gestures.workspace_swipe = false;
        input = {
          follow_mouse = true;
          force_no_accel = true;
          kb_layout = "us,ru";
          kb_options = "grp:win_space_toggle";
          natural_scroll = false;
          numlock_by_default = true;
          sensitivity = mkDefault 0.3;
          scroll_method = "2fg";
          tablet = {
            active_area_position = "50 60";
            active_area_size = "39 22";
            output = "current";
          };
          touchpad = {
            clickfinger_behavior = true;
            middle_button_emulation = true;
            natural_scroll = true;
            tap-to-click = true;
          };
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          vfr = false;
          vrr = 0; # TODO: Remove after flickering is fixed
        };
        monitor = [ ",highres,auto,1" ];

        "$mod" = "SUPER";
        bind = [
          "$mod,q,killactive,"
          "$mod,f,fullscreen,0"
          "$mod SHIFT,F,togglefloating,"
          "$mod CTRL,F,exec,hyprctl setprop active opaque toggle"
          "$mod,left,movefocus,l"
          "$mod,right,movefocus,r"
          "$mod,up,movefocus,u"
          "$mod,down,movefocus,d"
          "$mod SHIFT,left,movewindow,l"
          "$mod SHIFT,right,movewindow,r"
          "$mod SHIFT,up,movewindow,u"
          "$mod SHIFT,down,movewindow,d"
          "$mod,f5,forcerendererreload,"
          "$mod SHIFT,f5,exit,"
          "$mod,f11,exec,sleep 1 && hyprctl dispatch dpms off"
          "$mod,f12,exec,sleep 1 && hyprctl dispatch dpms on"

          "$mod,p,exec,${execApp} wlogout -b 5"
          # "$mod,escape,exec,${execApp} ${apps.monitor.cmd}"
          "$mod,w,exec,${execApp} ${apps.dmenu.desktop} -show run"
          "$mod CTRL,w,exec,${execApp} ${apps.dmenu.desktop} -show drun -modi drun -show-icons"
          "$mod,return,exec,${execApp} ${apps.term.cmd}"
          "$mod SHIFT,return,exec,${execApp} nop kitti3"
          "$mod,e,exec,${execApp} ${apps.editor.cmd}"
          "$mod,j,exec,${execApp} mpris-ctl prev"
          "$mod,k,exec,${execApp} mpris-ctl pp"
          "$mod,l,exec,${execApp} mpris-ctl next"
          "$mod SHIFT,J,exec,${execApp} mpris-ctl --player Spotify prev"
          "$mod SHIFT,K,exec,${execApp} mpris-ctl --player Spotify pp"
          "$mod SHIFT,L,exec,${execApp} mpris-ctl --player Spotify next"
          "$mod,m,exec,${execApp} pamixer -t"
          "$mod,comma,exec,${execApp} pamixer -d 5"
          "$mod,period,exec,${execApp} pamixer -i 5"
          "$mod SHIFT,comma,exec,${execApp} pamixer -d 2"
          "$mod SHIFT,period,exec,${execApp} pamixer -i 2"
          "$mod,i,exec,${execApp} pavucontrol"
          "$mod,d,exec,${execApp} ${apps.fm.cmd}"
          # "$mod,y,exec,${execApp} ${pkgs.youtube-to-mpv}/bin/yt-mpv"
          # "$mod SHIFT,Y,exec,${execApp} ${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video"
          "$mod,print,exec,${execApp} grim $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && notify-send 'Screenshot Saved'"
          "$mod CTRL,print,exec,${execApp} grim - | wl-copy && notify-send 'Screenshot Copied to Clipboard'"
          "$mod SHIFT,print,exec,${execApp} grim -g '$(slurp)' $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && notify-send 'Screenshot Saved'"
          "$mod CTRLSHIFT,print,exec,${execApp} grim -g '$(slurp)' - | wl-copy && notify-send 'Screenshot Copied to Clipboard'"
          ",xf86audioplay,exec,${execApp} mpris-ctl pp"
          ",xf86audionext,exec,${execApp} mpris-ctl next"
          ",xf86audioprev,exec,${execApp} mpris-ctl prev"
          ",xf86audiolowervolume,exec,${execApp} pamixer -d 5"
          ",xf86audioraisevolume,exec,${execApp} pamixer -i 5"
          "SHIFT,xf86audiolowervolume,exec,${execApp} pamixer -d 2"
          "SHIFT,xf86audioraisevolume,exec,${execApp} pamixer -i 2"
          ",xf86audiomute,exec,${execApp} pamixer -t"
          "$mod,s,togglegroup,"
          "$mod,x,togglesplit,"
          "$mod,c,changegroupactive,b"
          "$mod,v,changegroupactive,f"
          "$mod,V,exec,${execApp} cliphist list | ${apps.dmenu.desktop} -dmenu | cliphist decode | wl-copy"

          "$mod,1,workspace,1"
          "$mod,2,workspace,2"
          "$mod,3,workspace,3"
          "$mod,4,workspace,4"
          "$mod,5,workspace,5"
          "$mod,6,workspace,6"
          "$mod,7,workspace,7"
          "$mod,8,workspace,8"
          "$mod,9,workspace,name:Email"
          "$mod,0,workspace,name:Steam"
          "$mod,b,workspace,name:Music"
          "$mod,t,workspace,name:Messengers"
          "$mod,g,workspace,name:Games"
          "$mod SHIFT,1,movetoworkspacesilent,1"
          "$mod SHIFT,2,movetoworkspacesilent,2"
          "$mod SHIFT,3,movetoworkspacesilent,3"
          "$mod SHIFT,4,movetoworkspacesilent,4"
          "$mod SHIFT,5,movetoworkspacesilent,5"
          "$mod SHIFT,6,movetoworkspacesilent,6"
          "$mod SHIFT,7,movetoworkspacesilent,7"
          "$mod SHIFT,8,movetoworkspacesilent,8"
          "$mod SHIFT,9,movetoworkspacesilent,name:Email"
          "$mod SHIFT,0,movetoworkspacesilent,name:Steam"
          "$mod SHIFT,B,movetoworkspacesilent,name:Music"
          "$mod SHIFT,T,movetoworkspacesilent,name:Messengers"
          "$mod SHIFT,g,workspace,name:Games"
          "ALT,1,movetoworkspacesilent,1"
          "ALT,2,movetoworkspacesilent,2"
          "ALT,3,movetoworkspacesilent,3"
          "ALT,4,movetoworkspacesilent,4"
          "ALT,5,movetoworkspacesilent,5"
          "ALT,6,movetoworkspacesilent,6"
          "ALT,7,movetoworkspacesilent,7"
          "ALT,8,movetoworkspacesilent,8"
          "ALT,9,movetoworkspacesilent,name:Email"
          "ALT,0,movetoworkspacesilent,name:Steam"
          "ALT,b,movetoworkspacesilent,name:Music"
          "ALT,t,movetoworkspacesilent,name:Messengers"
          "ALT,g,movetoworkspacesilent,name:Games"
          "$mod ALT,1,movetoworkspace,1"
          "$mod ALT,2,movetoworkspace,2"
          "$mod ALT,3,movetoworkspace,3"
          "$mod ALT,4,movetoworkspace,4"
          "$mod ALT,5,movetoworkspace,5"
          "$mod ALT,6,movetoworkspace,6"
          "$mod ALT,7,movetoworkspace,7"
          "$mod ALT,8,movetoworkspace,8"
          "$mod ALT,9,movetoworkspace,name:Email"
          "$mod ALT,0,movetoworkspace,name:Steam"
          "$mod ALT,b,movetoworkspace,name:Music"
          "$mod ALT,t,movetoworkspace,name:Messengers"
          "$mod ALT,g,movetoworkspace,name:Games"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        env = mapAttrs (n: v: "${n}=${v}") {

        };
        exec = map (x: "${execApp} ${x}") [

        ];
        exec-once = map (x: "${execApp} ${x}") (
          [
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
          ]
          ++ config.startupApplications
        );
        windowrule = [
          "center,class:^(Waydroid)$"
          "float,class:^(gamescope)$"
          "float,class:^(Waydroid)$"
          "opaque,class:.*(jellyfin).*"
          "opaque,class:.*(qemu).*"
          "opaque,class:.*(virt-manager).*"
          "opaque,class:^(.*winbox64.exe)$"
          "opaque,class:^(Chromium-browser)$"
          "opaque,class:^(firefox)$"
          "opaque,class:^(gamescope)$"
          "opaque,class:^(mpv)$"
          "opaque,class:^(starrail.exe)$"
          "opaque,class:^(steam)$"
          "opaque,class:^(Waydroid)$"
          "size 1600 900,class:^(Waydroid)$"
          "tile,class:^(.*winbox64.exe)$"
          "tile,title:^(Spotify)$"
          "workspace name:Email silent,class:^(geary)$"
          "workspace name:Email silent,class:^(thunderbird)$"
          "workspace name:Messengers silent,class:^(org.telegram.desktop)$"
          "workspace name:Music silent,title:^(Spotify)$"
          "workspace name:Steam silent,class:^(.gamescope-wrapped)$,title:(Steam)"
          "workspace name:Steam silent,class:^(steam)$"
        ];
      };
    };
  };
}
