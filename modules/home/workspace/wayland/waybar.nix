{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.theme) fonts;
  cfg = config.ataraxia.wayland.waybar;
in
{
  options.ataraxia.wayland.waybar = {
    enable = mkEnableOption "Enable waybar";
    laptopWidgets = mkEnableOption "Enable laptop widgets (e.g. battery)";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      # style = builtins.readFile ./style.css;
      systemd.enable = true;
      systemd.target = "graphical-session.target";
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          # margin = "8 8 0 8";
          modules-left =
            [
              "hyprland/workspaces"
              # "wireplumber"
            ]
            ++ lib.optionals cfg.laptopWidgets [
              "battery"
              "backlight"
            ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "tray"
            "disk"
            "cpu"
            # "temperature"
            "memory"
            "clock"
          ];
          backlight = {
            device = "intel_backlight";
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
            # min-length = 7;
          };
          battery = {
            interval = 60;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "<span color=\"#e0af68\">󱐌</span> {capacity}%";
            format-icons = [
              "<span color=\"#f7768e\"> </span>"
              "<span color=\"#f7768e\"> </span>"
              "<span color=\"#7aa2f7\"> </span>"
              "<span color=\"#7aa2f7\"> </span>"
              "<span color=\"#7aa2f7\"> </span>"
            ];
            on-update = "$HOME/.config/waybar/scripts/check_battery.sh";
          };
          clock = {
            format = "{:%a, %d %b, %H:%M}";
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#c0caf5'><b>{}</b></span>";
                days = "<span color='#c0caf5'><b>{}</b></span>";
                weeks = "<span color='#7dcfff'><b>W{}</b></span>";
                weekdays = "<span color='#ff9e64'><b>{}</b></span>";
                today = "<span color='#f7768e'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-click-middle = "shift_reset";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };
          cpu = {
            interval = 4;
            format = "<span color=\"#7aa2f7\">      </span>{usage}%";
          };
          disk = {
            interval = 60;
            format = "<span color=\"#7aa2f7\">      </span>{free}";
            path = "/home";
          };
          "hyprland/window" = {
            max-length = 64;
          };
          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            disable-scroll = true;
            format-icons = {
              "10" = "0";
              "Messengers" = "Msg";
              "Music" = "Mus";
            };
          };
          memory = {
            format = "<span color=\"#7aa2f7\">     </span>{used}GiB";
            interval = 4;
          };
          temperature = {
            # "hwmon-path" = "/sys/class/hwmon/hwmon0/temp1_input";
            critical-threshold = 80;
            format = "<span color=\"#7aa2f7\">\uf4f5     </span>{temperatureC}°C";
            format-critical = "<span color=\"#f7768e\"> </span>{temperatureC}°C";
            interval = 4;
          };
          tray = {
            icon-size = 12;
            spacing = 6;
          };
          wireplumber = {
            scroll-step = 5;
            format = "<span color=\"#7aa2f7\">{icon} </span>{volume}%";
            format-muted = "<span color=\"#f7768e\">\ueee8   </span>Muted";
            format-bluetooth = "<span color=\"#7aa2f7\">\uf282 </span>{volume}%";
            on-click-right = "blueman-manager";
            format-icons = [
              "\uf026 "
              "\uf027 "
              "\uf028 "
            ];
            on-click = "pavucontrol";
          };
        };
      };
      style =
        let
          accent = "lavender";
        in
        ''
          /* @import "catppuccin.css"; */

          * {
            font-family: "${fonts.mono.family}", feather;
            font-weight: 500;
            font-size: ${toString fonts.size.small}pt;
            color: @text;
          }

          /* main waybar */
          window#waybar {
            padding: 0;
            margin: 0;
            /* background: rgba(26, 27, 38, 0.7); */
            background: @base;
          }

          /* when hovering over modules */
          tooltip {
            background: @base;
            border-radius: 5%;
          }

          #workspaces button {
            padding: 2px;
          }

          /* Sets active workspace to have a solid line on the bottom */
          #workspaces button.active {
            border-bottom: 2px solid @${accent};
            border-radius: 0;
            margin-top: 2px;
            transition: all 0.5s ease-in-out;
          }

          /* More workspace stuff for highlighting on hover */
          #workspaces button.focused {
            color: @subtext0;
          }

          #workspaces button.urgent {
            color: #f7768e;
          }

          #workspaces button:hover {
            background: @crust;
            color: @text;
          }

          /* Sets background, padding, margins, and borders for (all) modules */
          #workspaces,
          #clock,
          #window,
          #temperature,
          #disk,
          #cpu,
          #memory,
          #network,
          #wireplumber,
          #tray,
          #backlight,
          #battery {
            /* background: rgba(26, 27, 38, 0); */
            background: @base;
            padding: 0 10px;
            border: 0;
          }

          #workspaces {
            padding-right: 0px;
          }

          /* Hide window module when not focused on window or empty workspace */
          window#waybar.empty #window {
            padding: 0;
            margin: 0;
            opacity: 0;
          }

          /* Set up rounding to make these modules look like separate pills */
          #tray {
            color: @${accent};
            border-radius: 12px;
            margin-right: 4px;
          }

          #window {
            border-radius: 12px;
          }

          /* close right side of bar */
          #temperature {
            border-radius: 12px 0 0 12px;
          }

          /* close left side of bar */
          #battery {
            border-radius: 0 12px 12px 0;
          }
        '';
    };
  };
}
