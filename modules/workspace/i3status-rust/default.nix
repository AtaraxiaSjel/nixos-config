{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific;
with import ../../../support.nix { inherit pkgs config lib; };
let scripts = import ./scripts pkgs config;
in {
  home-manager.users.alukard.xsession.windowManager.i3.extraConfig = ''
    bar {
      id top
      font pango:Roboto Mono 11, FontAwesome 11
      mode dock
      hidden_state hide
      position top
      status_command ${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config.toml
      workspace_buttons yes
      strip_workspace_numbers no
      tray_output primary
      colors {
        background $bg
        statusline $fg
        separator $alt
        focused_workspace $bg $bg $blue
        active_workspace $bg $bg $green
        inactive_workspace $bg $bg $fg
        urgent_workspace $bg $bg $orange
        binding_mode $bg $bg $yellow
      }
    }
  '';

  # TODO: rewrite concat
  home-manager.users.alukard.xdg.configFile."i3status-rust/config.toml".text = lib.concatStrings [''
    theme = "slick"
    icons = "awesome"

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
    driver = "pulseaudio"

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