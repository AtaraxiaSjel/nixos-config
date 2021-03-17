{ config, lib, pkgs, ... }:
with config.deviceSpecific; {

  services.acpid.enable = true;
  services.acpid.logEvents = false;

  services.redshift = {
    enable = true;
    temperature.day = 5500;
    temperature.night = 3000;
  };

  services.earlyoom = {
    enable = devInfo.ram < 16;
    freeMemThreshold = 5;
    freeSwapThreshold = 100;
  };

  # Enable zram, disable zswap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 60;
    numDevices = 1;
  };
  boot.kernelParams = [ "zswap.enabled=0" ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.samsungUnifiedLinuxDriver pkgs.gutenprint ];
  };

  hardware.sane.enable = true;
  services.saned.enable = true;

  services.fstrim = {
    enable = isSSD;
    interval = "weekly";
  };

  services.udev.packages = [ pkgs.stlink ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  systemd.services.systemd-udev-settle.enable = false;

  services.upower.enable = true;
}
