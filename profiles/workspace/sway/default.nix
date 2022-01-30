{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
  apps = config.defaultApplications;
  # lock_fork =
  #   pkgs.writeShellScript "lock_fork" "sudo /run/current-system/sw/bin/lock &";
  # lock = pkgs.writeShellScript "lock"
  #   "swaymsg 'output * dpms off'; sudo /run/current-system/sw/bin/lock; swaymsg 'output * dpms on'";
in {
  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;
  programs.sway.extraPackages = lib.mkForce (with pkgs; [
    swayidle
    swaylock-effects
    xwayland
    wl-clipboard
    libsForQt5.qt5.qtwayland
    gsettings_desktop_schemas
  ]);

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };

  users.users.alukard.extraGroups = [ "sway" ];

  environment.loginShellInit = lib.mkAfter ''
    [[ "$(tty)" == /dev/tty1 ]] && {
      pass unlock
      exec sway 2> /tmp/sway.debug.log
    }
  '';

  home-manager.users.alukard.wayland.windowManager.sway = let
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
  in {
    enable = true;
    config = rec {
      assigns = {
        # "" = [
        #   { class = "Chromium"; }
        #   { app_id = "firefox"; }
        #   { class = "Firefox"; }
        # ];
        "" = [
          { class = "spotify"; }
          { title = "spt"; }
        ];
        "" = [
          { class = "^Telegram"; }
        ];
      };
      fonts = {
        names = [ "${thm.fonts.main.family}" ];
        style = "Regular";
        size = thm.fontSizes.micro.float;
      };

      bars = [ ];

      colors = rec {
        background = "#${thm.base00-hex}";
        unfocused = {
          text = "#${thm.base02-hex}";
          border = "#${thm.base01-hex}";
          background = "#${thm.base00-hex}";
          childBorder = "#${thm.base01-hex}";
          indicator = "#${thm.base07-hex}";
        };
        focusedInactive = unfocused;
        urgent = unfocused // {
          text = "#${thm.base05-hex}";
          border = "#${thm.base09-hex}";
          childBorder = "#${thm.base09-hex}";
        };
        focused = unfocused // {
          childBorder = "#${thm.base03-hex}";
          border = "#${thm.base03-hex}";
          background = "#${thm.base01-hex}";
          text = "#${thm.base05-hex}";
        };
      };

      gaps = {
        inner = 15;
        smartGaps = true;
        smartBorders = "on";
      };
      focus.followMouse = false;
      focus.forceWrapping = false;
      modifier = "Mod4";
      window = {
        border = 0;
        titlebar = false;
        commands = [
          {
            command = "border pixel 2px";
            criteria = { window_role = "popup"; };
          }
          # {
          #   command = "sticky enable";
          #   criteria = { floating = ""; };
          # }
          {
            command = "move to workspace ";
            criteria = { class = "Spotify"; };
          }
          {
            command = "floating enable";
            criteria = { instance = "origin.exe"; };
          }
        ];
      };
      startup = (map (command: { inherit command; }) config.startupApplications)
        ++ [
          { command = "${importGsettings}"; always = true; }
          {
            always = true;
            command = ''
              swayidle -w timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' '';
          }
          # {
          #   command =
          #     "swayidle -w before-sleep '${lock_fork}' lock '${lock_fork}' unlock 'pkill -9 swaylock'";
          # }
        ];

      keybindings = let
        script = name: content: "exec ${pkgs.writeScript name content}";
        workspaces = (builtins.genList (x: [ (toString x) (toString x) ]) 10)
          ++ [ [ "c" "" ] [ "t" "" ] ];
      in ({
        "${modifier}+q" = "kill";
        "${modifier}+Shift+q" =
          "move container to workspace temp; [workspace=__focused__] kill; workspace temp; move container to workspace temp; workspace temp";
        "${modifier}+w" = "exec ${apps.dmenu.cmd}";
        "${modifier}+Return" = "exec ${apps.term.cmd}";
        "${modifier}+Shift+Return" = "nop kitti3";
        "${modifier}+e" = "exec ${apps.editor.cmd}";
        "${modifier}+o" = "layout toggle all";

        "${modifier}+Left" = "focus child; focus left";
        "${modifier}+Right" = "focus child; focus right";
        "${modifier}+Up" = "focus child; focus up";
        "${modifier}+Down" = "focus child; focus down";
        "${modifier}+Control+Left" = "focus parent; focus left";
        "${modifier}+Control+Right" = "focus parent; focus right";
        "${modifier}+Control+Up" = "focus parent; focus up";
        "${modifier}+Control+Down" = "focus parent; focus down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+Shift+Left" = "move left";

        "${modifier}+bracketleft" = "workspace prev";
        "${modifier}+bracketright" = "workspace next";

        # "${modifier}+a" = "focus child; focus left";
        # "${modifier}+d" = "focus child; focus right";
        # "${modifier}+w" = "focus child; focus up";
        # "${modifier}+s" = "focus child; focus down";
        # "${modifier}+Control+a" = "focus parent; focus left";
        # "${modifier}+Control+d" = "focus parent; focus right";
        # "${modifier}+Control+w" = "focus parent; focus up";
        # "${modifier}+Control+s" = "focus parent; focus down";
        # "${modifier}+Shift+w" = "move up";
        # "${modifier}+Shift+s" = "move down";
        # "${modifier}+Shift+d" = "move right";
        # "${modifier}+Shift+a" = "move left";

        "${modifier}+f" = "fullscreen toggle; floating toggle";
        "${modifier}+r" = "mode resize";
        "${modifier}+Shift+f" = "floating toggle";

        "${modifier}+Escape" = "exec ${apps.monitor.cmd}";

        "${modifier}+j" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl prev";
        "${modifier}+k" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl pp";
        "${modifier}+l" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl next";
        "${modifier}+Shift+j" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify prev";
        "${modifier}+Shift+k" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify pp";
        "${modifier}+Shift+l" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl --player Spotify next";
        "${modifier}+m" = "exec ${pkgs.pamixer}/bin/pamixer -t";
        "${modifier}+comma" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
        "${modifier}+period" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
        "${modifier}+Shift+comma" = "exec ${pkgs.pamixer}/bin/pamixer -d 2";
        "${modifier}+Shift+period" = "exec ${pkgs.pamixer}/bin/pamixer -i 2";
        "${modifier}+i" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

        "${modifier}+d" = "exec ${apps.fm.cmd}";
          "${modifier}+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv";
          "${modifier}+Shift+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video";

        "${modifier}+Print" = script "screenshot"
          "${pkgs.grim}/bin/grim Pictures/$(date +'%Y-%m-%d+%H:%M:%S').png";

        "${modifier}+Control+Print" = script "screenshot-copy"
          "${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";

        "--release ${modifier}+Shift+Print" = script "screenshot-area" ''
          ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" Pictures/$(date +'%Y-%m-%d+%H:%M:%S').png'';

        "--release ${modifier}+Control+Shift+Print" =
          script "screenshot-area-copy" ''
            ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';

        "${modifier}+x" = "focus output right";
        "${modifier}+Shift+x" = "move workspace to output right";
        "${modifier}+F5" = "reload";
        "${modifier}+Shift+F5" = "exit";
        "${modifier}+Shift+h" = "layout splith";
        "${modifier}+Shift+v" = "layout splitv";
        "${modifier}+h" = "split h";
        "${modifier}+v" = "split v";
        "${modifier}+F1" = "move to scratchpad";
        "${modifier}+F2" = "scratchpad show";
        "${modifier}+F11" = "output * dpms off";
        "${modifier}+F12" = "output * dpms on";
        # "${modifier}+End" = "exec ${lock}";
        "${modifier}+p" = "sticky toggle";
        "${modifier}+backslash" =
          script "0x0" ''wl-paste | curl -F"file=@-" https://0x0.st | wl-copy'';
        "${modifier}+b" = "focus mode_toggle";

        "XF86AudioPlay" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl pp";
        "XF86AudioNext" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl next";
        "XF86AudioPrev" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl prev";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
        "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
        "Shift+XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 2";
        "Shift+XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 2";
        "button2" = "kill";
        "--whole-window ${modifier}+button2" = "kill";
      } // builtins.listToAttrs (builtins.map (x: {
        name = "${modifier}+${builtins.elemAt x 0}";
        value = "workspace ${builtins.elemAt x 1}";
      }) workspaces) // builtins.listToAttrs (builtins.map (x: {
        name = "${modifier}+Shift+${builtins.elemAt x 0}";
        value = "move container to workspace ${builtins.elemAt x 1}";
      }) workspaces));
      keycodebindings = { };
      workspaceLayout = "tabbed";
      workspaceAutoBackAndForth = true;
      input = {
        "type:touchpad" = {
          accel_profile = "adaptive";
          dwt = "enabled";
          middle_emulation = "enabled";
          natural_scroll = "enabled";
          tap = "enabled";
        };
        "type:mouse" = {
          accel_profile = "flat";
          natural_scroll = "disabled";
        };
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:win_space_toggle";
        };
        "3468:12:C-Media_USB_Headphone_Set" = {
          events = "disabled";
        };
      };
      output = {
        "*".bg = "${/. + ../../../misc/wallpaper} fill";
        "*".scale = "1";
      };
    };
    wrapperFeatures = { gtk = true; };
    xwayland = true;
    extraConfig = ''
      default_border pixel 1
      hide_edge_borders --i3 smart
      exec pkill swaynag
      exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
      exec_always --no-startup-id kitti3 -p BC
    '';
    extraSessionCommands = ''
      # export SDL_VIDEODRIVER=wayland
      export GDK_BACKEND=wayland
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland
      export _JAVA_AWT_WM_NONPARENTING=1
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };
}
