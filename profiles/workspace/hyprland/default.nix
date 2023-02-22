{ pkgs, lib, config, inputs, ... }:
let
  thm = config.lib.base16.theme;
  apps = config.defaultApplications;
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    config="/home/${config.mainuser}/.config/gtk-3.0/settings.ini"
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

  screen-ocr = pkgs.writeShellScriptBin "screen-ocr" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp) - | ${pkgs.tesseract5}/bin/tesseract -l eng - - | ${pkgs.wl-clipboard}/bin/wl-copy"
  '';

  hyprpaper-pkg = inputs.hyprpaper.packages.${pkgs.hostPlatform.system}.hyprpaper;
in with config.deviceSpecific; with lib; {
  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland.enable = true;

  environment.sessionVariables = {
    NIX_OZONE_WL = "1";
  };

  home-manager.users.${config.mainuser} = {
    imports = [
      inputs.hyprland.homeManagerModules.default
    ];

    home.packages = [ pkgs.wl-clipboard hyprpaper-pkg ];

    home.file.".config/hypr/hyprpaper.conf".text = ''
      preload = ${/. + ../../../misc/wallpaper.png}
      wallpaper = ,${/. + ../../../misc/wallpaper.png}
      ipc = off
    '';

    programs.zsh.loginExtra = let
      initScript = pkgs.writeShellScriptBin "wrappedHypr" ''
        # export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        # export XDG_CURRENT_DESKTOP=sway
        #export _JAVA_AWT_WM_NONPARENTING=1
        # export XCURSOR_SIZE=${toString thm.cursorSize}

        exec Hyprland 2> /tmp/hyprland.debug.log
      '';
    in lib.mkAfter ''
      [[ "$(tty)" == /dev/tty1 ]] && {
        pass unlock
        exec ${initScript}/bin/wrappedHypr
      }
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      # xwayland.hidpi = false;
      nvidiaPatches = false;
      systemdIntegration = true;
      recommendedEnvironment = true;
      extraConfig = let
        modifier = "SUPER";
        script = name: content: "${pkgs.writeScript name content}";
      in concatStrings [
        ''
          ${if config.device == "AMD-Workstation" then ''
            monitor=DP-1,2560x1440@59951,0x0,1
          '' else ''
            monitor=,highres,auto,1
          ''}
          general {
            apply_sens_to_raw=false
            border_size=1
            no_border_on_floating=false
            gaps_in=6
            gaps_out=16
            col.active_border=0xAA${thm.base08-hex}
            col.inactive_border=0xAA${thm.base0A-hex}
            # layout=dwindle    # Available: dwindle, master, default is dwindle
            # no_cursor_warps=true
            sensitivity=1
            col.group_border=0xCC${thm.base0A-hex}
            col.group_border_active=0xAA${thm.base08-hex}
          }
          decoration {
            # rounding=8
            rounding=0
            multisample_edges=true
            active_opacity=0.92
            inactive_opacity=0.75
            fullscreen_opacity=1.0
            blur=true
            blur_size=2
            blur_passes=3
            blur_ignore_opacity=true
            drop_shadow=true
            shadow_range=12
            # shadow_render_power=int    # (1 - 4), in what power to render the falloff (more power, the faster the falloff)
            shadow_ignore_window=true
            col.shadow=0xAA${thm.base08-hex}
            shadow_offset=0 0
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
              sensitivity=0.35
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
            vfr=1
            vrr=1
          }
        '' ''
          bindm=${modifier},mouse:272,movewindow
          bindm=${modifier},mouse:273,resizewindow

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
          bind=${modifier},f5,forcerendererreload,
          bind=${modifier}SHIFT,f5,exit,
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
          bind=${modifier},print,exec,${pkgs.grim}/bin/grim $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && ${pkgs.libnotify}/bin/notify-send 'Screenshot Saved'
          bind=${modifier}CTRL,print,exec,${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send 'Screenshot Copied to Clipboard'
          bind=${modifier}SHIFT,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" $(xdg-user-dir PICTURES)/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && ${pkgs.libnotify}/bin/notify-send 'Screenshot Saved'
          bind=${modifier}CTRLSHIFT,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send 'Screenshot Copied to Clipboard'
          bind=,xf86audioplay,exec,${pkgs.mpris-ctl}/bin/mpris-ctl pp
          bind=,xf86audionext,exec,${pkgs.mpris-ctl}/bin/mpris-ctl next
          bind=,xf86audioprev,exec,${pkgs.mpris-ctl}/bin/mpris-ctl prev
          bind=,xf86audiolowervolume,exec,${pkgs.pamixer}/bin/pamixer -d 5
          bind=,xf86audioraisevolume,exec,${pkgs.pamixer}/bin/pamixer -i 5
          bind=SHIFT,xf86audiolowervolume,exec,${pkgs.pamixer}/bin/pamixer -d 2
          bind=SHIFT,xf86audioraisevolume,exec,${pkgs.pamixer}/bin/pamixer -i 2
          bind=,xf86audiomute,exec,${pkgs.pamixer}/bin/pamixer -t
          bind=${modifier},s,togglegroup,
          bind=${modifier},x,togglesplit,
          bind=${modifier},c,changegroupactive,b
          bind=${modifier},v,changegroupactive,f
          bindr=${modifier},insert,exec,${screen-ocr}/bin/screen-ocr

          bind=${modifier},1,workspace,1
          bind=${modifier},2,workspace,2
          bind=${modifier},3,workspace,3
          bind=${modifier},4,workspace,4
          bind=${modifier},5,workspace,5
          bind=${modifier},6,workspace,6
          bind=${modifier},7,workspace,7
          bind=${modifier},8,workspace,8
          bind=${modifier},9,workspace,9
          bind=${modifier},0,workspace,name:Steam
          bind=${modifier},b,workspace,name:Music
          bind=${modifier},t,workspace,name:Messengers
          bind=${modifier},Cyrillic_E,workspace,name:Messengers
          bind=${modifier}SHIFT,1,movetoworkspacesilent,1
          bind=${modifier}SHIFT,2,movetoworkspacesilent,2
          bind=${modifier}SHIFT,3,movetoworkspacesilent,3
          bind=${modifier}SHIFT,4,movetoworkspacesilent,4
          bind=${modifier}SHIFT,5,movetoworkspacesilent,5
          bind=${modifier}SHIFT,6,movetoworkspacesilent,6
          bind=${modifier}SHIFT,7,movetoworkspacesilent,7
          bind=${modifier}SHIFT,8,movetoworkspacesilent,8
          bind=${modifier}SHIFT,9,movetoworkspacesilent,9
          bind=${modifier}SHIFT,0,movetoworkspacesilent,name:Steam
          bind=${modifier}SHIFT,B,movetoworkspacesilent,name:Music
          bind=${modifier}SHIFT,T,movetoworkspacesilent,name:Messengers
          bind=${modifier}SHIFT,Cyrillic_E,movetoworkspacesilent,name:Messengers
          bind=ALT,1,movetoworkspacesilent,1
          bind=ALT,2,movetoworkspacesilent,2
          bind=ALT,3,movetoworkspacesilent,3
          bind=ALT,4,movetoworkspacesilent,4
          bind=ALT,5,movetoworkspacesilent,5
          bind=ALT,6,movetoworkspacesilent,6
          bind=ALT,7,movetoworkspacesilent,7
          bind=ALT,8,movetoworkspacesilent,8
          bind=ALT,9,movetoworkspacesilent,9
          bind=ALT,0,movetoworkspacesilent,name:Steam
          bind=ALT,b,movetoworkspacesilent,name:Music
          bind=ALT,t,movetoworkspacesilent,name:Messengers
          bind=ALT,Cyrillic_E,movetoworkspacesilent,name:Messengers
          bind=${modifier}ALT,1,movetoworkspace,1
          bind=${modifier}ALT,2,movetoworkspace,2
          bind=${modifier}ALT,3,movetoworkspace,3
          bind=${modifier}ALT,4,movetoworkspace,4
          bind=${modifier}ALT,5,movetoworkspace,5
          bind=${modifier}ALT,6,movetoworkspace,6
          bind=${modifier}ALT,7,movetoworkspace,7
          bind=${modifier}ALT,8,movetoworkspace,8
          bind=${modifier}ALT,9,movetoworkspace,9
          bind=${modifier}ALT,0,movetoworkspace,name:Steam
          bind=${modifier}ALT,b,movetoworkspace,name:Music
          bind=${modifier}ALT,t,movetoworkspace,name:Messengers
          bind=${modifier}ALT,Cyrillic_E,movetoworkspace,name:Messengers
        '' ''
          windowrule=workspace name:Steam silent,Steam
          windowrule=workspace name:Music silent,Spotify
          # windowrule=opaque,Spotify
          windowrule=tile,Spotify
          windowrule=workspace name:Messengers silent,telegramdesktop
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
          windowrule=opaque,^(.+WinBox.+)$
          windowrule=tile,^(.+WinBox.+)$
        '' ''
          exec=${importGsettings}
          # exec-once=swayidle -w timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
          exec-once=${hyprpaper-pkg}/bin/hyprpaper
          exec-once=hyprctl setcursor ${config.lib.base16.theme.cursorTheme} ${toString config.lib.base16.theme.cursorSize}
        ''
        (concatMapStrings (c: "exec-once=" + c + "\n") config.startupApplications)

      ];
    };
  };
}
