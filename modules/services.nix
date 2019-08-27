{ config, lib, pkgs, ... }: {

  # services.acpid.enable = true;

  # services.mopidy = {
  #   enable = true;

  #   extensionPackages = with pkgs; [ mopidy-gmusic ];
  #   configuration = (if (!isNull config.secrets.gpmusic) then ''
  #     [gmusic]
  #     username = ${config.secrets.gpmusic.user}
  #     password = ${config.secrets.gpmusic.password}
  #     deviceid = ${config.secrets.gpmusic.deviceid}
  #     bitrate = 128
  #   '' else
  #     "") + ''
  #       [mpd]
  #       hostname = 0.0.0.0
  #     '';
  # };
  services.earlyoom = {
    enable = config.devices.${config.device}.ram < 12;
    freeMemThreshold = 5;
    freeSwapThreshold = 100;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };
  programs.dconf.enable = true;

  services.accounts-daemon.enable = true;
  services.avahi.enable = true;

  systemd.services.systemd-udev-settle.enable = false;

  services.upower.enable = true;

  virtualisation.docker.enable = config.deviceSpecific.isHost;
  virtualisation.virtualbox.host = lib.mkIf config.deviceSpecific.isHost {
    enable = true;
    # enableHardening = false;
    enableExtensionPack = true;
  };

}
