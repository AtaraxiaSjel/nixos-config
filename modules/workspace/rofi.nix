{ pkgs, config, lib, ... }: {
  home-manager.users.alukard.programs.rofi = {
    enable = true;
    font = "Roboto Mono 14";
    terminal = "\${rxvt_unicode}/bin/urxvt";
    # theme = "custom.rasi";
    theme = "~/.cache/wal/colors-rofi-dark.rasi";
  };
}