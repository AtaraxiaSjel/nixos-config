{ config, ... }: {
  programs.gamemode = {
    enable = config.deviceSpecific.isGaming;
    settings.general.inhibit_screensaver = 0;
  };
}