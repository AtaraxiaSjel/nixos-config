{ pkgs, config, ... }:
let
  thm = config.themes.colors;
  apps = config.defaultApplications;
in {
  environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

  home-manager.users.alukard.xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = rec {
      assigns = {
        # "" = [ { class = "Chromium"; } { class = "Firefox"; } ];
        "" = [ { class = "Spotify"; } ];
        "" = [
          { class = "^Telegram"; }
          { class = "^VK"; }
          { class = "^trojita"; }
          { title = "weechat"; }
          { class = "nheko"; }
        ];
        "ﱘ" = [{ class = "cantata"; }];
      };
      fonts = [ "RobotoMono 9" ];

      bars = [ ];

      # colors = rec {
      #   background = thm.bg;
      #   unfocused = {
      #     border = thm.dark;
      #     background = thm.bg;
      #     text = thm.alt;
      #     indicator = thm.fg;
      #     childBorder = thm.dark;
      #   };
      #   focusedInactive = unfocused;
      #   urgent = unfocused // {
      #     border = thm.orange;
      #     text = thm.fg;
      #     childBorder = thm.orange;
      #   };
      #   focused = unfocused // {
      #     border = thm.blue;
      #     background = thm.dark;
      #     text = thm.fg;
      #     childBorder = thm.blue;
      #   };
      # };
      colors = rec {
        background = "\$bg";
        unfocused = {
          border = "\$dark";
          background = "\$bg";
          text = "\$alt";
          indicator = "\$fg";
          childBorder = "\$dark";
        };
        focusedInactive = unfocused;
        urgent = unfocused // {
          border = "\$purple";
          text = "\$fg";
          childBorder = "\$purple";
        };
        focused = unfocused // {
          border = "\$blue";
          background = "\$dark";
          text = "\$fg";
          childBorder = "\$blue";
        };
      };
      gaps = {
        inner = 6;
        smartGaps = true;
        smartBorders = "on";
      };
      focus.mouseWarping = false;
      focus.followMouse = false;
      modifier = "Mod4";
      window = {
        border = 1;
        titlebar = false;
        hideEdgeBorders = "smart";
        commands = [
          {
            command = "border pixel 2px";
            criteria = { window_role = "popup"; };
          }
        ];
      };
      startup = map (a: { notification = false; } // a) [
        { command = "${pkgs.xorg.xrdb}/bin/xrdb -merge ~/.Xresources"; }
        { command = "${pkgs.pywal}/bin/wal -R"; }
        { command = "${pkgs.spotifywm}/bin/spotifywm"; }
      ];
      keybindings = let
        script = name: content: "exec ${pkgs.writeScript name content}";
        workspaces = (builtins.genList (x: [ (toString x) (toString x) ]) 10)
          ++ [ [ "c" "" ] [ "t" "" ] [ "m" "ﱘ" ] ];
        # moveMouse = ''
        #   "sh -c 'eval `${pkgs.xdotool}/bin/xdotool \
        #         getactivewindow \
        #         getwindowgeometry --shell`; ${pkgs.xdotool}/bin/xdotool \
        #         mousemove \
        #         $((X+WIDTH/2)) $((Y+HEIGHT/2))'"'';
        in ({
          "${modifier}+q" = "kill";
          "${modifier}+w" = "exec ${apps.dmenu.cmd}";
          "${modifier}+Return" = "exec ${apps.term.cmd}";
          "${modifier}+e" = "exec ${apps.editor.cmd}";
          "${modifier}+l" = "layout toggle all";

          "${modifier}+Left" = "focus child; focus left";
          "${modifier}+Right" = "focus child; focus right";
          "${modifier}+Up" = "focus child; focus up";
          "${modifier}+Down" = "focus child; focus down";
          "${modifier}+Control+Left" = "focus parent; focus left";
          "${modifier}+Control+Right" = "focus parent; focus right";
          "${modifier}+Control+Up" = "focus parent; focus up";
          # "${modifier}+Control+Down" = "focus parent; focus down; ${moveMouse}";
          # "${modifier}+Left" = "focus child; focus left; ${moveMouse}";
          # "${modifier}+Right" = "focus child; focus right; ${moveMouse}";
          # "${modifier}+Up" = "focus child; focus up; ${moveMouse}";
          # "${modifier}+Down" = "focus child; focus down; ${moveMouse}";
          # "${modifier}+Control+Left" = "focus parent; focus left; ${moveMouse}";
          # "${modifier}+Control+Right" = "focus parent; focus right; ${moveMouse}";
          # "${modifier}+Control+Up" = "focus parent; focus up; ${moveMouse}";
          # "${modifier}+Control+Down" = "focus parent; focus down; ${moveMouse}";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Right" = "move right";
          "${modifier}+Shift+Left" = "move left";

          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+r" = "mode resize";
          "${modifier}+Shift+f" = "floating toggle";
          "${modifier}+j" = "focus mode_toggle";

          "${modifier}+d" = "exec ${apps.fm.cmd}";
          "${modifier}+Escape" = "exec ${apps.monitor.cmd}";
          "${modifier}+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv";
          "${modifier}+Shift+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video";

          "${modifier}+Shift+l" = "exec ${pkgs.i3lock-fancy}/bin/i3lock-fancy -f Roboto-Medium";

          "${modifier}+Print" = script "screenshot"
            "${pkgs.maim}/bin/maim Pictures/$(date +%s).png";
          "${modifier}+Control+Print" = script "screenshot-copy"
            "${pkgs.maim}/bin/maim | xclip -selection clipboard -t image/png";
          "--release ${modifier}+Shift+Print" = script "screenshot-area"
            "${pkgs.maim}/bin/maim -s Pictures/$(date +%s).png";
          "--release ${modifier}+Control+Shift+Print" = script "screenshot-area-copy"
            "${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png";

          "${modifier}+x" = "move workspace to output right";
          "${modifier}+k" = "exec '${pkgs.xorg.xkill}/bin/xkill'";
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

          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "--release button2" = "kill";
          "--whole-window ${modifier}+button2" = "kill";

        } // builtins.listToAttrs (builtins.map (x: {
          name = "${modifier}+${builtins.elemAt x 0}";
          value = "workspace ${builtins.elemAt x 1}";
        }) workspaces) // builtins.listToAttrs (builtins.map (x: {
          name = "${modifier}+Shift+${builtins.elemAt x 0}";
          value = "move container to workspace ${builtins.elemAt x 1}";
        }) workspaces));
      keycodebindings = {
        "122" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
        "123" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
        "121" = "exec ${pkgs.pamixer}/bin/pamixer -t";
      };
      workspaceLayout = "tabbed";
    };
    extraConfig = ''
      set_from_resource $bg i3wm.background "{background}"
      set_from_resource $fg i3wm.foreground "{foreground}"
      set_from_resource $dark i3wm.color0 "{color0}"
      set_from_resource $alt i3wm.color 8"{color8}"
      set_from_resource $purple i3wm.color5 "{color5}"
      set_from_resource $blue i3wm.color4 "{color4}"
    '';
  };
}
