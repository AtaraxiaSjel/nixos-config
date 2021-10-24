{ pkgs, config, lib, ... }:
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
        "" = [
          { class = "spotify"; }
          { title = "spt"; }
        ];
        "" = [
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
      startup = lib.mkIf (!config.deviceSpecific.isISO) (map (command: { inherit command; }) config.startupApplications);
      keybindings = let
        script = name: content: "exec ${pkgs.writeScript name content}";
        workspaces = (builtins.genList (x: [ (toString x) (toString x) ]) 10)
          ++ [ [ "c" "" ] [ "t" "" ] ];
      in ({
          "${modifier}+q" = "kill";
          "${modifier}+Shift+q" = "move container to workspace temp; [workspace=__focused__] kill; workspace temp; move container to workspace temp; workspace temp";
          "${modifier}+w" = "exec ${apps.dmenu.cmd}";
          "${modifier}+Return" = "exec ${apps.term.cmd}";
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

          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+r" = "mode resize";
          "${modifier}+Shift+f" = "floating toggle";
          "${modifier}+Escape" = "exec ${apps.monitor.cmd}";

          "${modifier}+j" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl prev";
          "${modifier}+k" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl pp";
          "${modifier}+l" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl next";
          "${modifier}+m" = "exec ${pkgs.pamixer}/bin/pamixer -t";
          "${modifier}+comma" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
          "${modifier}+period" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
          "${modifier}+Shift+comma" = "exec ${pkgs.pamixer}/bin/pamixer -d 2";
          "${modifier}+Shift+period" = "exec ${pkgs.pamixer}/bin/pamixer -i 2";
          "${modifier}+i" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";

          "${modifier}+d" = "exec ${apps.fm.cmd}";
          "${modifier}+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv";
          "${modifier}+Shift+y" = "exec ${pkgs.youtube-to-mpv}/bin/yt-mpv --no-video";

          "${modifier}+Shift+l" = "exec ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 8 3";

          "${modifier}+Print" = script "screenshot"
            "${pkgs.maim}/bin/maim ~/Pictures/$(date +%s).png";
          "${modifier}+Control+Print" = script "screenshot-copy"
            "${pkgs.maim}/bin/maim | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
          "--release ${modifier}+Shift+Print" = script "screenshot-area"
            "${pkgs.maim}/bin/maim -s ~/Pictures/$(date +%s).png";
          "--release ${modifier}+Control+Shift+Print" = script "screenshot-area-copy"
            "${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";

          "${modifier}+x" = "move workspace to output right";
          "${modifier}+F5" = "reload";
          "${modifier}+Shift+F5" = "exit";
          "${modifier}+Shift+h" = "layout splith";
          "${modifier}+Shift+v" = "layout splitv";
          "${modifier}+h" = "split h";
          "${modifier}+v" = "split v";
          "${modifier}+F1" = "move to scratchpad";
          "${modifier}+F2" = "scratchpad show";
          "${modifier}+F12" = "exec xset dpms force off";

          "XF86AudioPlay" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl pp";
          "XF86AudioNext" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl next";
          "XF86AudioPrev" = "exec ${pkgs.mpris-ctl}/bin/mpris-ctl prev";
          "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
          "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
          "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
          "Shift+XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 2";
          "Shift+XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 2";
          "--release button2" = "kill";
          "--whole-window ${modifier}+button2" = "kill";

        } // builtins.listToAttrs (builtins.map (x: {
          name = "${modifier}+${builtins.elemAt x 0}";
          value = "workspace ${builtins.elemAt x 1}";
        }) workspaces) // builtins.listToAttrs (builtins.map (x: {
          name = "${modifier}+Shift+${builtins.elemAt x 0}";
          value = "move container to workspace ${builtins.elemAt x 1}";
        }) workspaces)
      );
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
