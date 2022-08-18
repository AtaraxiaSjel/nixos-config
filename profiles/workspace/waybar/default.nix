{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "wlr/workspaces" ];
        modules-right = [
          "cpu"
          "custom/separator"
          "disk"
          "custom/separator"
          "clock"
          "custom/separator"
          "tray"
        ];
        cpu = {
          interval = 4;
          format = "{usage}";
        };
        disk = {
          interval = 60;
          format = "{free}";
          path = "/";
        };
        clock = {
          format = "{:%a, %d %b, %H:%M}";
        };
        "custom/separator" = {
          format = "|";
          interval = "once";
          tooltip = false;
        };
        "wlr/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "10" = "0";
            "Messengers" = "Msg";
            "Music" = "Mus";
          };
        };
      };
    };
    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: alpha(@theme_bg_color, 0.8);
          border-bottom: 3px solid alpha(@borders, 0.8);
          color: white;
        }

        tooltip {
          background: rgba(43, 48, 59, 0.5);
          border: 1px solid rgba(100, 114, 125, 0.5);
        }
        tooltip label {
          color: white;
        }

        #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: white;
          border-bottom: 3px solid transparent;
        }

        #workspaces button.focused {
          background: #64727D;
          border-bottom: 3px solid white;
        }

        #workspaces button.active {
          background: @theme_selected_bg_color;
        }

        #mode, #clock, #battery {
          padding: 0 10px;
        }

        #mode {
          background: #64727D;
          border-bottom: 3px solid white;
        }

        #clock {
          background-color: #64727D;
        }

        #battery {
          background-color: #ffffff;
          color: black;
        }

        #battery.charging {
          color: white;
          background-color: #26A65B;
        }

        @keyframes blink {
        to {
            background-color: #ffffff;
            color: black;
          }
        }

        #battery.warning:not(.charging) {
          background: #f53c3c;
          color: white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
    '';
    systemd.enable = true;
    systemd.target = "hyprland-session.target";
  };
}