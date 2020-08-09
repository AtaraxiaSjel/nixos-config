{ pkgs, config, ... }:
let
  thm = config.lib.base16.theme;
  apps = config.defaultApplications;
  # lock = pkgs.writeShellScript "lock" "sudo /run/current-system/sw/bin/lock";
in {
  environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

  home-manager.users.alukard.xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = rec {
      assigns = {
        "" = [
          { class = "Spotify"; }
          { class = "PulseEffects"; }
          { class = "spt"; }
        ];
        "" = [
          { class = "^Telegram"; }
        ];
        "ﱘ" = [{ class = "cantata"; }];
      };
      fonts = [ "${thm.fontMono} 9" ];

      bars = [ ];

      colors = {
        focused = {
          border = "#${thm.base05-hex}";
          background = "#${thm.base00-hex}";
          text = "#${thm.base0D-hex}";
          indicator = "#${thm.base0D-hex}";
          childBorder = "#${thm.base0C-hex}";
        };
        focusedInactive = {
          border = "#${thm.base01-hex}";
          background = "#${thm.base01-hex}";
          text = "#${thm.base05-hex}";
          indicator = "#${thm.base03-hex}";
          childBorder = "#${thm.base01-hex}";
        };
        unfocused = {
          border = "#${thm.base01-hex}";
          background = "#${thm.base00-hex}";
          text = "#${thm.base05-hex}";
          indicator = "#${thm.base01-hex}";
          childBorder = "#${thm.base01-hex}";
        };
        urgent = {
          border = "#${thm.base08-hex}";
          background = "#${thm.base08-hex}";
          text = "#${thm.base00-hex}";
          indicator = "#${thm.base08-hex}";
          childBorder = "#${thm.base08-hex}";
        };
        placeholder = {
          border = "#${thm.base00-hex}";
          background = "#${thm.base00-hex}";
          text = "#${thm.base05-hex}";
          indicator = "#${thm.base00-hex}";
          childBorder = "#${thm.base00-hex}";
        };
        background = "#${thm.base07-hex}";
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
        { command = "${pkgs.tdesktop}/bin/telegram-desktop"; }
        {
          command =
            "${pkgs.keepassxc}/bin/keepassxc --keyfile=/home/alukard/.passwords.key /home/alukard/nixos-config/misc/Passwords.kdbx";
        }
      ];
      keybindings = let
        script = name: content: "exec ${pkgs.writeScript name content}";
        workspaces = (builtins.genList (x: [ (toString x) (toString x) ]) 10)
          ++ [ [ "c" "" ] [ "t" "" ] [ "m" "ﱘ" ] ];
        moveMouse = ''
          exec "sh -c 'eval `${pkgs.xdotool}/bin/xdotool \
                getactivewindow \
                getwindowgeometry --shell`; ${pkgs.xdotool}/bin/xdotool \
                mousemove \
                $((X+WIDTH/2)) $((Y+HEIGHT/2))'"'';
      in ({
          "${modifier}+q" = "kill";
          "${modifier}+w" = "exec ${apps.dmenu.cmd}";
          "${modifier}+Return" = "exec ${apps.term.cmd}";
          "${modifier}+e" = "exec ${apps.editor.cmd}";
          # "${modifier}+l" = "layout toggle all";

          "${modifier}+Left" = "focus child; focus left; ${moveMouse}";
          "${modifier}+Right" = "focus child; focus right; ${moveMouse}";
          "${modifier}+Up" = "focus child; focus up; ${moveMouse}";
          "${modifier}+Down" = "focus child; focus down; ${moveMouse}";
          "${modifier}+Control+Left" = "focus parent; focus left; ${moveMouse}";
          "${modifier}+Control+Right" = "focus parent; focus right; ${moveMouse}";
          "${modifier}+Control+Up" = "focus parent; focus up; ${moveMouse}";
          "${modifier}+Control+Down" = "focus parent; focus down; ${moveMouse}";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Right" = "move right";
          "${modifier}+Shift+Left" = "move left";

          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+r" = "mode resize";
          "${modifier}+Shift+f" = "floating toggle";
          "${modifier}+Escape" = "exec ${apps.monitor.cmd}";

          "${modifier}+j" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "${modifier}+k" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "${modifier}+l" = "exec ${pkgs.playerctl}/bin/playerctl next";

          "${modifier}+d" = "exec ${apps.fm.cmd}";
          "${modifier}+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv";
          "${modifier}+Shift+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video";

          "${modifier}+Shift+l" = "exec ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 8 3";

          "${modifier}+Print" = script "screenshot"
            "${pkgs.maim}/bin/maim ~/Pictures/$(date +%s).png";
          "${modifier}+Control+Print" = script "screenshot-copy"
            "${pkgs.maim}/bin/maim | xclip -selection clipboard -t image/png";
          "--release ${modifier}+Shift+Print" = script "screenshot-area"
            "${pkgs.maim}/bin/maim -s ~/Pictures/$(date +%s).png";
          "--release ${modifier}+Control+Shift+Print" = script "screenshot-area-copy"
            "${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png";

          "${modifier}+x" = "move workspace to output right";
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
      default_border pixel 1
      hide_edge_borders smart

      # Set colors
      set $base00 #${thm.base00-hex}
      set $base01 #${thm.base01-hex}
      set $base02 #${thm.base02-hex}
      set $base03 #${thm.base03-hex}
      set $base04 #${thm.base04-hex}
      set $base05 #${thm.base05-hex}
      set $base06 #${thm.base06-hex}
      set $base07 #${thm.base07-hex}
      set $base08 #${thm.base08-hex}
      set $base09 #${thm.base09-hex}
      set $base0A #${thm.base0A-hex}
      set $base0B #${thm.base0B-hex}
      set $base0C #${thm.base0C-hex}
      set $base0D #${thm.base0D-hex}
      set $base0E #${thm.base0E-hex}
      set $base0F #${thm.base0F-hex}
    '';
  };
}
