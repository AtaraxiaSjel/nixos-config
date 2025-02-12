{ pkgs, lib, config, ... }:
let
  inherit (lib) concatStrings concatMapStrings;
  inherit (config.deviceSpecific) isLaptop;

  thm = config.lib.base16.theme;
  apps = config.defaultApplications;
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    config="/home/${config.mainuser}/.config/gtk-4.0/settings.ini"
    if [ ! -f "$config" ]; then exit 1; fi
    gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
    ${gsettings} set ${gnomeSchema} gtk-theme "$gtk_theme"
    ${gsettings} set ${gnomeSchema} icon-theme "$icon_theme"
    ${gsettings} set ${gnomeSchema} cursor-theme "$cursor_theme"
    ${gsettings} set ${gnomeSchema} font-name "$font_name"
  '';

  screen-ocr = pkgs.writeShellScript "screen-ocr" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.tesseract}/bin/tesseract -l eng - - | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in {
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  services.greetd = let
    session = {
      command = "${lib.getExe config.programs.uwsm.package} start hyprland-uwsm.desktop";
      user = config.mainuser;
    };
  in {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = session;
      initial_session = session;
    };
  };

  home-manager.users.${config.mainuser} = {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      xwayland.enable = true;
      extraConfig = let
        modifier = "SUPER";
      in concatStrings [
        ''
          ${if config.device == "AMD-Workstation" then ''
            monitor=DP-3,2560x1440@164.998993,0x0,1
            monitor=HDMI-A-1,1920x1080@60,-1920x360,1
            monitor=,highres,auto,1
          '' else ''
            monitor=,highres,auto,1
          ''}
          general {
            border_size=1
            no_border_on_floating=false
            gaps_in=6
            gaps_out=16
            col.active_border=0xAA${thm.base08-hex}
            col.inactive_border=0xAA${thm.base0A-hex}
            col.nogroup_border=0xCC${thm.base0A-hex}
            col.nogroup_border_active=0xAA${thm.base08-hex}
          }
          decoration {
            rounding=0
            active_opacity=0.95
            inactive_opacity=0.85
            fullscreen_opacity=1.0
            blur {
              enabled=true
              size=2
              passes=3
              ignore_opacity=true
            }
            shadow {
              enabled=true
              range=12
              ignore_window=true
              color=0xAA${thm.base08-hex}
              offset=0 0
            }
          }
          animations {
            enabled=true
          }
          input {
            kb_layout=us,ru
            kb_options=grp:win_space_toggle

            follow_mouse=true
            natural_scroll=false
            numlock_by_default=true
            force_no_accel=true
            ${if config.device == "AMD-Workstation" then ''
              sensitivity=0.3
            '' else ''
              sensitivity=1.3
            ''}
            ${lib.optionalString isLaptop "scroll_method=2fg"}

            touchpad {
              natural_scroll=true
              clickfinger_behavior=true
              middle_button_emulation=true
              tap-to-click=true
            }
          }
          gestures {
            workspace_swipe=no
          }
          misc {
            disable_hyprland_logo=true
            disable_splash_rendering=true
            mouse_move_enables_dpms=true
            vfr=true
            vrr=1
          }
        '' ''
          bindm=${modifier},mouse:272,movewindow
          bindm=${modifier},mouse:273,resizewindow

          bind=${modifier},q,killactive,
          bind=${modifier},f,fullscreen,0
          bind=${modifier}SHIFT,F,togglefloating,
          bind=${modifier}CTRL,F,exec,hyprctl setprop active opaque toggle
          bind=${modifier},left,movefocus,l
          bind=${modifier},right,movefocus,r
          bind=${modifier},up,movefocus,u
          bind=${modifier},down,movefocus,d
          bind=${modifier}SHIFT,left,movewindow,l
          bind=${modifier}SHIFT,right,movewindow,r
          bind=${modifier}SHIFT,up,movewindow,u
          bind=${modifier}SHIFT,down,movewindow,d
          bind=${modifier},f5,forcerendererreload,
          bind=${modifier}SHIFT,f5,exit,
          bind=${modifier},f11,exec,sleep 1 && hyprctl dispatch dpms off
          bind=${modifier},f12,exec,sleep 1 && hyprctl dispatch dpms on

          bind=${modifier},p,exec,uwsm app -- ${pkgs.wlogout}/bin/wlogout -b 5
          bind=${modifier},escape,exec,uwsm app -- ${apps.monitor.cmd}
          bind=${modifier},w,exec,uwsm app -- ${apps.dmenu.desktop} -show run
          bind=${modifier}CTRL,w,exec,uwsm app -- ${apps.dmenu.desktop} -show drun -modi drun -show-icons
          bind=${modifier},return,exec,uwsm app -- ${apps.term.cmd}
          bind=${modifier}SHIFT,return,exec,uwsm app -- nop kitti3
          bind=${modifier},e,exec,uwsm app -- ${apps.editor.cmd}
          bind=${modifier},j,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl prev
          bind=${modifier},k,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl pp
          bind=${modifier},l,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl next
          bind=${modifier}SHIFT,J,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify prev
          bind=${modifier}SHIFT,K,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify pp
          bind=${modifier}SHIFT,L,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify next
          bind=${modifier},m,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -t
          bind=${modifier},comma,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -d 5
          bind=${modifier},period,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -i 5
          bind=${modifier}SHIFT,comma,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -d 2
          bind=${modifier}SHIFT,period,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -i 2
          bind=${modifier},i,exec,uwsm app -- ${pkgs.pavucontrol}/bin/pavucontrol
          bind=${modifier},d,exec,uwsm app -- ${apps.fm.cmd}
          bind=${modifier},y,exec,uwsm app -- ${pkgs.youtube-to-mpv}/bin/yt-mpv
          bind=${modifier}SHIFT,Y,exec,uwsm app -- ${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video
          bind=${modifier},print,exec,uwsm app -- ${pkgs.grim}/bin/grim $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && ${pkgs.libnotify}/bin/notify-send 'Screenshot Saved'
          bind=${modifier}CTRL,print,exec,uwsm app -- ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send 'Screenshot Copied to Clipboard'
          bind=${modifier}SHIFT,print,exec,uwsm app -- ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && ${pkgs.libnotify}/bin/notify-send 'Screenshot Saved'
          bind=${modifier}CTRLSHIFT,print,exec,uwsm app -- ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send 'Screenshot Copied to Clipboard'
          bind=,xf86audioplay,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl pp
          bind=,xf86audionext,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl next
          bind=,xf86audioprev,exec,uwsm app -- ${pkgs.mpris-ctl}/bin/mpris-ctl prev
          bind=,xf86audiolowervolume,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -d 5
          bind=,xf86audioraisevolume,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -i 5
          bind=SHIFT,xf86audiolowervolume,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -d 2
          bind=SHIFT,xf86audioraisevolume,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -i 2
          bind=,xf86audiomute,exec,uwsm app -- ${pkgs.pamixer}/bin/pamixer -t
          bind=${modifier},s,togglegroup,
          bind=${modifier},x,togglesplit,
          bind=${modifier},c,changegroupactive,b
          bind=${modifier},v,changegroupactive,f
          bind=${modifier},V,exec,uwsm app -- ${pkgs.cliphist}/bin/cliphist list | ${apps.dmenu.desktop} -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
          bindr=${modifier},insert,exec,uwsm app -- ${screen-ocr}

          bind=${modifier},1,workspace,1
          bind=${modifier},2,workspace,2
          bind=${modifier},3,workspace,3
          bind=${modifier},4,workspace,4
          bind=${modifier},5,workspace,5
          bind=${modifier},6,workspace,6
          bind=${modifier},7,workspace,7
          bind=${modifier},8,workspace,8
          bind=${modifier},9,workspace,name:Email
          bind=${modifier},0,workspace,name:Steam
          bind=${modifier},b,workspace,name:Music
          bind=${modifier},t,workspace,name:Messengers
          bind=${modifier},g,workspace,name:Games
          bind=${modifier},Cyrillic_E,workspace,name:Messengers
          bind=${modifier}SHIFT,1,movetoworkspacesilent,1
          bind=${modifier}SHIFT,2,movetoworkspacesilent,2
          bind=${modifier}SHIFT,3,movetoworkspacesilent,3
          bind=${modifier}SHIFT,4,movetoworkspacesilent,4
          bind=${modifier}SHIFT,5,movetoworkspacesilent,5
          bind=${modifier}SHIFT,6,movetoworkspacesilent,6
          bind=${modifier}SHIFT,7,movetoworkspacesilent,7
          bind=${modifier}SHIFT,8,movetoworkspacesilent,8
          bind=${modifier}SHIFT,9,movetoworkspacesilent,name:Email
          bind=${modifier}SHIFT,0,movetoworkspacesilent,name:Steam
          bind=${modifier}SHIFT,B,movetoworkspacesilent,name:Music
          bind=${modifier}SHIFT,T,movetoworkspacesilent,name:Messengers
          bind=${modifier}SHIFT,g,workspace,name:Games
          bind=${modifier}SHIFT,Cyrillic_E,movetoworkspacesilent,name:Messengers
          bind=ALT,1,movetoworkspacesilent,1
          bind=ALT,2,movetoworkspacesilent,2
          bind=ALT,3,movetoworkspacesilent,3
          bind=ALT,4,movetoworkspacesilent,4
          bind=ALT,5,movetoworkspacesilent,5
          bind=ALT,6,movetoworkspacesilent,6
          bind=ALT,7,movetoworkspacesilent,7
          bind=ALT,8,movetoworkspacesilent,8
          bind=ALT,9,movetoworkspacesilent,name:Email
          bind=ALT,0,movetoworkspacesilent,name:Steam
          bind=ALT,b,movetoworkspacesilent,name:Music
          bind=ALT,t,movetoworkspacesilent,name:Messengers
          bind=ALT,g,movetoworkspacesilent,name:Games
          bind=ALT,Cyrillic_E,movetoworkspacesilent,name:Messengers
          bind=${modifier}ALT,1,movetoworkspace,1
          bind=${modifier}ALT,2,movetoworkspace,2
          bind=${modifier}ALT,3,movetoworkspace,3
          bind=${modifier}ALT,4,movetoworkspace,4
          bind=${modifier}ALT,5,movetoworkspace,5
          bind=${modifier}ALT,6,movetoworkspace,6
          bind=${modifier}ALT,7,movetoworkspace,7
          bind=${modifier}ALT,8,movetoworkspace,8
          bind=${modifier}ALT,9,movetoworkspace,name:Email
          bind=${modifier}ALT,0,movetoworkspace,name:Steam
          bind=${modifier}ALT,b,movetoworkspace,name:Music
          bind=${modifier}ALT,t,movetoworkspace,name:Messengers
          bind=${modifier}ALT,g,movetoworkspace,name:Games
          bind=${modifier}ALT,Cyrillic_E,movetoworkspace,name:Messengers
        '' ''
          windowrulev2=workspace name:Email silent,class:^(geary)$
          windowrulev2=workspace name:Steam silent,class:^(steam)$
          windowrulev2=workspace name:Steam silent,class:^(.gamescope-wrapped)$,title:(Steam)
          windowrulev2=workspace name:Music silent,title:^(Spotify)$
          windowrulev2=tile,title:^(Spotify)$
          windowrulev2=workspace name:Messengers silent,class:^(org.telegram.desktop)$
          windowrule=opaque,firefox
          windowrule=opaque,chromium-browser
          windowrule=opaque,mpv

          windowrule=float,Waydroid
          windowrule=size 1600 900,Waydroid
          windowrule=center,Waydroid
          windowrule=opaque,Waydroid
          windowrule=opaque,qemu

          windowrule=opaque,steam_app.*
          windowrule=float,steam_app.*

          windowrule=opaque,virt-manager
          windowrulev2=opaque,class:^(.*winbox64.exe)$
          windowrulev2=tile,class:^(.*winbox64.exe)$
          windowrulev2=opaque,class:^(starrail.exe)$

          windowrule=opaque,.*jellyfin.*
        '' ''
          env=GDK_BACKEND=wayland,x11
          env=QT_QPA_PLATFORM=wayland;xcb
          env=SDL_VIDEODRIVER=wayland
          env=CLUTTER_BACKEND=wayland
          env=XDG_CURRENT_DESKTOP=Hyprland
          env=XDG_SESSION_DESKTOP=Hyprland
          env=XDG_SESSION_TYPE=wayland
          env=QT_AUTO_SCREEN_SCALE_FACTOR=1
          env=QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          # env=QT_QPA_PLATFORMTHEME=qt5ct
          env=GSETTINGS_SCHEMA_DIR=${pkgs.glib.getSchemaPath pkgs.gsettings-desktop-schemas}
        '' ''
          exec=uwsm app -- ${importGsettings}
          exec=hyprctl setcursor ${config.lib.base16.theme.cursorTheme} ${toString config.lib.base16.theme.cursorSize}
          exec-once=uwsm app -- ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
          exec-once=uwsm app -- ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store
          exec-once=uwsm app -- ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store
          ${lib.optionalString (!isLaptop) "exec-once=${pkgs.mpvpaper}/bin/mpvpaper -p -o \"no-audio loop\" '*' ${../../../misc/wallpaper.mkv}"}
        ''
        (concatMapStrings (c: "exec-once=uwsm app -- " + c + "\n") config.startupApplications)
      ];
    };
  };
}
