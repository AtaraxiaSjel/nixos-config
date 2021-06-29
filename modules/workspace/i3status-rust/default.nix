{ pkgs, config, lib, ... }:
let
  scripts = import ./scripts pkgs config;
  thm = config.lib.base16.theme;
in {
  home-manager.users.alukard = {
    xsession.windowManager.i3.config.bars = [{
      id = "default";
      # fonts = [ "${thm.iconFont} Solid ${thm.microFontSize}" "${thm.fallbackIcon} ${thm.microFontSize}" "${thm.powerlineFont} SemiBold ${thm.microFontSize}" ];
      fonts = {
        names = [ "${thm.powerlineFont}" "${thm.iconFont}" "${thm.fallbackIcon}" ];
        style = "Regular";
        # size = thm.microFontSize;
        size = 10.0;
      };
      position = "top";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
      workspaceNumbers = false;
      colors = {
        background = "#${thm.base00-hex}";
        statusline = "#${thm.base02-hex}";
        separator = "#${thm.base04-hex}";
        focusedWorkspace = {
          background = "#${thm.base00-hex}";
          border = "#${thm.base00-hex}";
          text = "#${thm.base0D-hex}";
        };
        activeWorkspace = {
          background = "#${thm.base03-hex}";
          border = "#${thm.base00-hex}";
          text = "#${thm.base00-hex}";
        };
        inactiveWorkspace = {
          background = "#${thm.base01-hex}";
          border = "#${thm.base00-hex}";
          text = "#${thm.base05-hex}";
        };
        urgentWorkspace = {
          background = "#${thm.base00-hex}";
          border = "#${thm.base0A-hex}";
          text = "#${thm.base05-hex}";
        };
        bindingMode = {
          background = "#${thm.base0A-hex}";
          border = "#${thm.base00-hex}";
          text = "#${thm.base00-hex}";
        };
      };

    }];

    xdg.configFile."i3status-rust/config.toml".text = lib.concatStrings [''

      [theme]
      name = "solarized-dark"
      [theme.overrides]
      idle_bg = "#${thm.base00-hex}"
      idle_fg = "#${thm.base05-hex}"
      info_bg = "#${thm.base0C-hex}"
      info_fg = "#${thm.base00-hex}"
      good_bg = "#${thm.base0B-hex}"
      good_fg = "#${thm.base00-hex}"
      warning_bg = "#${thm.base0A-hex}"
      warning_fg = "#${thm.base00-hex}"
      critical_bg = "#${thm.base08-hex}"
      critical_fg = "#${thm.base00-hex}"


      # Material Icons Cheatsheet [https://shanfan.github.io/material-icons-cheatsheet/]
      # Font Awesome Cheatsheet [https://fontawesome.com/icons?d=gallery&m=free]
      [icons]
      name = "awesome5"
      [icons.overrides]
      backlight_empty = " 🌑 "
      backlight_full = " 🌕 "
      backlight_partial1 = " 🌘 "
      backlight_partial2 = " 🌗 "
      backlight_partial3 = " 🌖 "
      # bat_charging = ""
      # bat_discharging = ""
      # bat_full = ""
      # bat = ""
      # cogs = ""
      cpu = ""
      # gpu = ""
      # mail = ""
      memory_mem = ""
      memory_swap = ""
      music_next = ""
      music_pause = ""
      music_play = ""
      music_prev = ""
      music = ""
      net_down = ""
      net_up = ""
      ### net_up = ""
      net_wired = ""
      net_wireless = ""
      ### net_wired = ""
      ### net_wireless = ""
      # ping = ""
      # thermometer = ""
      # time = ""
      # toggle_off = ""
      # toggle_on = ""
      # update = ""
      # uptime = ""
      volume_empty = ""
      volume_full = ""
      volume_half = ""
      volume_muted = ""
      # weather_clouds = ""
      # weather_default = ""
      # weather_rain = ""
      # weather_snow = ""
      # weather_sun = ""
      # weather_thunder = ""
      # xrandr = ""

      # [[block]]
      # block = "music"
      # buttons = ["play", "next"]

      [[block]]
      block = "net"
    ''
    (if config.device == "Dell-Laptop" then ''
      device = "wlo1"
    '' else "")
    (if config.device == "AMD-Workstation" then ''
      device = "enp9s0"
    '' else "")
    (if config.deviceSpecific.isLaptop then ''
      [[block]]
      block = "battery"
      interval = 10
      format = "{percentage} {time}"

      [[block]]
      block = "backlight"
    '' else "")
    ''
      [[block]]
      block = "custom"
      command = "${scripts.weather}"
      interval = 600

      [[block]]
      block = "sound"
      driver = "auto"
      ''
      (if config.device == "Dell-Laptop" then ''

      [[block]]
      block = "custom"
      command = "${scripts.cputemp}"
      interval = 5

      '' else "")
      ''
      [[block]]
      block = "cpu"
      interval = 1
      format = "{utilization} {frequency}"

      [[block]]
      block = "memory"
      display_type = "memory"
      format_mem = "{mem_avail;G}"
      format_swap = "{swap_free;G}"

      [[block]]
      block = "custom"
      command = "${scripts.df}"
      interval = 60

      [[block]]
      block = "custom"
      command = "${scripts.vpn-status}"
      interval = 60

      [[block]]
      block = "time"
      interval = 1
      format = "%a %Y/%m/%d %T"
    ''];
  };
}
