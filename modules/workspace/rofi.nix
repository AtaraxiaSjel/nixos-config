{ pkgs, config, lib, ... }: {
  home-manager.users.alukard.programs.rofi = {
    enable = true;
    font = "Roboto Mono 14";
    terminal = config.defaultApplications.term.cmd;
    theme = "~/.cache/wal/colors-rofi-dark.rasi";
  };
}