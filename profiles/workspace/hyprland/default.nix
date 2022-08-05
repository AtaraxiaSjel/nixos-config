{ pkgs, lib, config, inputs, ... }:
let
  thm = config.lib.base16.theme;
  apps = config.defaultApplications;
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    config="/home/alukard/.config/gtk-3.0/settings.ini"
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
in with config.deviceSpecific; with lib; {
  imports = [ inputs.hyprland.nixosModules.default ];
  programs.hyprland.enable = true;
  programs.hyprland.package = null;

  environment.loginShellInit = lib.mkAfter ''
    [[ "$(tty)" == /dev/tty1 ]] && {
      pass unlock
      exec Hyprland 2> /tmp/hyprland.debug.log
    }
  '';


  home-manager.users.alukard = {
    # home.packages = [ pkgs.hyprpaper ];
    imports = [
      inputs.hyprland.homeManagerModules.default
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = true;
      systemdIntegration = true;
      extraConfig = let
        modifier = "SUPER";
        script = name: content: "${pkgs.writeScript name content}";
      in concatStrings [
        ''

          monitor=DP-1,2560x1440@59951,0x0,1
          general {
            sensitivity=1.0
            apply_sens_to_raw=false
            main_mod=${modifier}
            border_size=3
            no_border_on_floating=false
            gaps_in=5
            gaps_out=8
            # col.active_border=col    # border color
            # col.inactive_border=col    # border color
            # cursor_inactive_timeout=0
            damage_tracking=full
            # layout=dwindle    # Available: dwindle, master, default is dwindle
            # no_cursor_warps=true
          }
          decoration {
            rounding=10
            multisample_edges=true
            active_opacity=0.9
            inactive_opacity=0.7
            fullscreen_opacity=1
            blur=true
            blur_size=2
            blur_passes=2
            # blur_ignore_opacity=false
            drop_shadow=true
            shadow_range=5
            # shadow_render_power=int    # (1 - 4), in what power to render the falloff (more power, the faster the falloff)
            shadow_ignore_window=false
            # col.shadow=col    # shadow color
            # shadow_offset=vec2
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
            sensitivity=1.0

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
            no_vfr=${boolToString (!isLaptop)}
            mouse_move_enables_dpms=true
          }
        '' ''
          bind=${modifier},q,killactive,
          bind=${modifier},f,fullscreen,0
          bind=${modifier}SHIFT,F,togglefloating,
          bind=${modifier},left,movefocus,l
          bind=${modifier},right,movefocus,r
          bind=${modifier},up,movefocus,u
          bind=${modifier},down,movefocus,d
          bind=${modifier}SHIFT,left,movewindow,l
          bind=${modifier}SHIFT,right,movewindow,r
          bind=${modifier}SHIFT,up,movewindow,u
          bind=${modifier}SHIFT,down,movewindow,d
          bind=${modifier},f5,exit,
          bind=${modifier}SHIFT,f5,forcerendererreload,
          bind=${modifier},f11,exec,sleep 1 && hyprctl dispatch dpms off
          bind=${modifier},f12,exec,sleep 1 && hyprctl dispatch dpms on


          bind=${modifier},escape,exec,${apps.monitor.cmd}
          bind=${modifier},w,exec,${apps.dmenu.cmd}
          bind=${modifier},return,exec,${apps.term.cmd}
          bind=${modifier}SHIFT,return,exec,nop kitti3
          bind=${modifier},e,exec,${apps.editor.cmd}
          bind=${modifier},j,exec,${pkgs.mpris-ctl}/bin/mpris-ctl prev
          bind=${modifier},k,exec,${pkgs.mpris-ctl}/bin/mpris-ctl pp
          bind=${modifier},l,exec,${pkgs.mpris-ctl}/bin/mpris-ctl next
          bind=${modifier}SHIFT,J,exec,${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify prev
          bind=${modifier}SHIFT,K,exec,${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify pp
          bind=${modifier}SHIFT,L,exec,${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify next
          bind=${modifier},m,exec,${pkgs.pamixer}/bin/pamixer -t
          bind=${modifier},comma,exec,${pkgs.pamixer}/bin/pamixer -d 5
          bind=${modifier},period,exec,${pkgs.pamixer}/bin/pamixer -i 5
          bind=${modifier}SHIFT,comma,exec,${pkgs.pamixer}/bin/pamixer -d 2
          bind=${modifier}SHIFT,period,exec,${pkgs.pamixer}/bin/pamixer -i 2
          bind=${modifier},i,exec,${pkgs.pavucontrol}/bin/pavucontrol
          bind=${modifier},d,exec,${apps.fm.cmd}
          bind=${modifier},y,exec,${pkgs.youtube-to-mpv}/bin/yt-mpv
          bind=${modifier}SHIFT,Y,exec,${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video
          bind=${modifier},print,exec,${pkgs.grim}/bin/grim $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && notify-send 'Screenshot Saved'
          bind=${modifier}CTRL,print,exec,${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy && notify-send 'Screenshot Copied to Clipboard'
          bind=${modifier}SHIFT,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && notify-send 'Screenshot Saved'
          bind=${modifier}CTRLSHIFT,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy && notify-send 'Screenshot Copied to Clipboard'
          bind=,xf86audioplay,exec,${pkgs.mpris-ctl}/bin/mpris-ctl pp
          bind=,xf86audionext,exec,${pkgs.mpris-ctl}/bin/mpris-ctl next
          bind=,xf86audioprev,exec,${pkgs.mpris-ctl}/bin/mpris-ctl prev
          bind=,xf86audiolowervolume,exec,${pkgs.pamixer}/bin/pamixer -d 5
          bind=,xf86audioraisevolume,exec,${pkgs.pamixer}/bin/pamixer -i 5
          bind=SHIFT,xf86audiolowervolume,exec,${pkgs.pamixer}/bin/pamixer -d 2
          bind=SHIFT,xf86audioraisevolume,exec,${pkgs.pamixer}/bin/pamixer -i 2
          bind=,xf86audiomute,exec,${pkgs.pamixer}/bin/pamixer -t

          bind=${modifier},1,workspace,1
          bind=${modifier},2,workspace,2
          bind=${modifier},3,workspace,3
          bind=${modifier},4,workspace,4
          bind=${modifier},5,workspace,5
          bind=${modifier},6,workspace,6
          bind=${modifier},7,workspace,7
          bind=${modifier},8,workspace,8
          bind=${modifier},9,workspace,9
          bind=${modifier},0,workspace,10
          bind=${modifier},c,workspace,name:Music
          bind=${modifier},t,workspace,name:Messengers
          bind=${modifier}SHIFT,1,movetoworkspacesilent,1
          bind=${modifier}SHIFT,2,movetoworkspacesilent,2
          bind=${modifier}SHIFT,3,movetoworkspacesilent,3
          bind=${modifier}SHIFT,4,movetoworkspacesilent,4
          bind=${modifier}SHIFT,5,movetoworkspacesilent,5
          bind=${modifier}SHIFT,6,movetoworkspacesilent,6
          bind=${modifier}SHIFT,7,movetoworkspacesilent,7
          bind=${modifier}SHIFT,8,movetoworkspacesilent,8
          bind=${modifier}SHIFT,9,movetoworkspacesilent,9
          bind=${modifier}SHIFT,0,movetoworkspacesilent,10
          bind=${modifier}SHIFT,C,workspace,name:Music
          bind=${modifier}SHIFT,T,workspace,name:Messengers
          bind=ALT,1,movetoworkspacesilent,1
          bind=ALT,2,movetoworkspacesilent,2
          bind=ALT,3,movetoworkspacesilent,3
          bind=ALT,4,movetoworkspacesilent,4
          bind=ALT,5,movetoworkspacesilent,5
          bind=ALT,6,movetoworkspacesilent,6
          bind=ALT,7,movetoworkspacesilent,7
          bind=ALT,8,movetoworkspacesilent,8
          bind=ALT,9,movetoworkspacesilent,9
          bind=ALT,0,movetoworkspacesilent,10
          bind=ALT,c,workspace,name:Music
          bind=ALT,t,workspace,name:Messengers

          bind=ALT,R,submap,resize # will switch to a submap called resize
          submap=resize # will start a submap called "resize"
          bind=,right,resizeactive,10 0
          bind=,left,resizeactive,-10 0
          bind=,up,resizeactive,0 -10
          bind=,down,resizeactive,0 10
          bind=SHIFT,right,resizeactive,40 0
          bind=SHIFT,left,resizeactive,-40 0
          bind=SHIFT,up,resizeactive,0 -40
          bind=SHIFT,down,resizeactive,0 40
          bind=SHIFT,return,submap,reset # use reset to go back to the global submap
          submap=reset # will reset the submap
        ''
        # (concatMapStrings (title: "windowrule=float,title:" + title) [
        #   "Steam - News" ".* - Chat" "^Settings$" ".* - event started" ".* CD key" "^Steam - Self Updater$"
        #   "^Screenshot Uploader$" "^Steam Guard - Computer Authorization Required$" "^Steam Keyboard$"
        # ])
        ''
          windowrule=workspace 10 silent,^Steam$
          windowrule=workspace name:Music silent,Spotify
          windowrule=workspace name:Messengers silent,^Telegram
          windowrule=opaque,^(Firefox.*)
        '' ''
          exec=${importGsettings}
          exec-once=swayidle -w timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
          exec-once=${pkgs.swaybg}/bin/swaybg -i ${/. + ../../../misc/wallpaper} -m fill
        ''
        (concatMapStrings (c: "exec-once=" + c + "\n") config.startupApplications)

      ];
    };
  };

}

          # exec-once=${script "set-wallpaper" ''
          #   MONITOR=$(hyprctl -j monitors | ${pkgs.jq}/bin/jq -r '.[] .name');
          #   hyprctl hyprpaper wallpaper $MONITOR,~/Pictures/myepicpng.png
          # ''}
