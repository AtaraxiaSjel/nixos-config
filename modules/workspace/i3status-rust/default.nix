{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific;
let
  scripts = import ./scripts pkgs config;
  thm = config.lib.base16.theme;
in {
  home-manager.users.alukard.xsession.windowManager.i3.extraConfig = ''
    bar {
      id top
      font pango:${thm.iconFont} Solid 10, ${thm.fallbackIcon} 10, ${thm.powerlineFont} SemiBold 10
      mode dock
      hidden_state hide
      position top
      status_command ${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config.toml
      workspace_buttons yes
      strip_workspace_numbers no
      tray_output primary
      colors {
        background #${thm.base00-hex}
        separator #${thm.base02-hex}
        statusline #${thm.base04-hex}
        focused_workspace #${thm.base00-hex} #${thm.base00-hex} #${thm.base0D-hex}
        active_workspace #${thm.base00-hex} #${thm.base03-hex} #${thm.base00-hex}
        inactive_workspace #${thm.base00-hex} #${thm.base01-hex} #${thm.base05-hex}
        urgent_workspace #${thm.base0A-hex} #${thm.base00-hex} #${thm.base05-hex}
        binding_mode #${thm.base00-hex} #${thm.base0A-hex} #${thm.base00-hex}
      }
    }
  '';

  home-manager.users.alukard.xdg.configFile."i3status-rust/config.toml".text = lib.concatStrings [''

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
    # backlight_empty = ""
    # backlight_full = ""
    # backlight_partial1 = ""
    # backlight_partial2 = ""
    # backlight_partial3 = ""
    # bat_charging = ""
    # bat_discharging = ""
    # bat_full = ""
    # bat = ""
    # cogs = ""
    cpu = "  "
    # gpu = ""
    # mail = ""
    memory_mem = "  "
    memory_swap = "  "
    music_next = ""
    music_pause = ""
    music_play = ""
    music_prev = ""
    music = "  "
    net_down = " "
    net_up = "  "
    ### net_up = " "
    net_wired = ""
    net_wireless = ""
    ### net_wired = "  "
    ### net_wireless = "  "
    # ping = ""
    # thermometer = ""
    # time = ""
    # toggle_off = ""
    # toggle_on = ""
    # update = ""
    # uptime = ""
    volume_empty = "  "
    volume_full = "  "
    volume_half = "  "
    volume_muted = " "
    # weather_clouds = ""
    # weather_default = ""
    # weather_rain = ""
    # weather_snow = ""
    # weather_sun = ""
    # weather_thunder = ""
    # xrandr = ""

    [[block]]
    block = "net"
  ''
  (if device == "Dell-Laptop" then ''
    device = "wlo1"
  '' else "")
  (if device == "AMD-Workstation" then ''
    device = "enp9s0"
  '' else "")
  (if isLaptop then ''
    [[block]]
    block = "battery"
    interval = 10
    format = "{percentage}% {time}"

    [[block]]
    block = "backlight"
  '' else "")
  ''
    [[block]]
    block = "custom"
    command = "${scripts.weather}"
    interval = 600

    [[block]]
    block = "music"
    buttons = ["play", "next"]

    [[block]]
    block = "sound"
    driver = "auto"

    [[block]]
    block = "cpu"
    interval = 1
    format = "{utilization}% {frequency}GHz"

    [[block]]
    block = "memory"
    display_type = "memory"
    format_mem = "{MAg}GiB"
    format_swap = "{SFg}GiB"

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
}