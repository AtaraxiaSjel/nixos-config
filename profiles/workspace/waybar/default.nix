{ config, pkgs, ... }:
with config.deviceSpecific; {
  home-manager.users.${config.mainuser}.programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin = "10 10 0 8";
        modules-left = [ "wlr/workspaces" ];
        modules-right = if isLaptop then [
          "cpu"
          "disk"
          "temperature"
          "custom/mem"
          "backlight"
          "battery"
          "clock"
          "tray"
        ] else [
          "cpu"
          "disk"
          "temperature"
          "custom/mem"
          "clock"
          "tray"
        ];
        cpu = {
          interval = 4;
          format = "{usage}%";
        };
        disk = {
          interval = 60;
          format = "{free}";
          path = "/home";
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
        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" "" "" ];
          tooltip = false;
        };
        "custom/mem" = {
          format = "{} ";
          interval = 3;
          exec = "${pkgs.procps}/bin/free -h | ${pkgs.gawk}/bin/awk '/Mem:/{printf $7}'";
          tooltip = false;
        };
        backlight = {
          device = "intel_backlight";
          format = "{percent}% {icon}";
          format-icons = [ "" "" "" "" "" "" "" ];
          min-length = 7;
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            "" "" "" "" "" "" "" "" "" ""
          ];
          on-update = "$HOME/.config/waybar/scripts/check_battery.sh";
        };
        clock = {
          format = "{:%a, %d %b, %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        tray = {
          icon-size = 16;
          spacing = 0;
        };
      };
    };
  };
}