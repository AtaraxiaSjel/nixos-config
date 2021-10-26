{ config, lib, pkgs, ... }:
with config.deviceSpecific; {

  services.acpid.enable = true;
  services.acpid.logEvents = false;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.btrbk.instances.home = {
    settings = {
      snapshot_preserve_min = "2d";
      snapshot_preserve = "7d";
      snapshot_dir = "/.snapshots";
      subvolume = "/home";
    };
    onCalendar = "daily";
  };

  services.earlyoom = {
    enable = devInfo.ram < 16;
    freeMemThreshold = 5;
    freeSwapThreshold = 100;
  };

  services.fstrim = {
    enable = isSSD;
    interval = "weekly";
  };

  services.redshift = {
    enable = true;
    temperature.day = 6500;
    temperature.night = 3000;
  };

  services.thermald.enable = isLaptop;

  services.tlp = {
    enable = isLaptop;
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_HWP_ON_AC = "balance_performance";
      CPU_HWP_ON_BAT = "balance_power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      SCHED_POWERSAVE_ON_AC = 0;
      SCHED_POWERSAVE_ON_BAT = 1;
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      DISK_DEVICES = "\"nvme0n1 sda\"";
      DISK_APM_LEVEL_ON_AC = "\"255 254\"";
      DISK_APM_LEVEL_ON_BAT = "\"255 254\"";
      SATA_LINKPWR_ON_BAT = "\"med_power_with_dipm max_performance\"";
      SATA_LINKPWR_ON_AC = "\"med_power_with_dipm max_performance\"";
    };
  };

  services.undervolt = lib.mkIf (config.device == "Dell-Laptop") {
    enable = true;
    coreOffset = -108; # -120
    gpuOffset = -48; # -54
  };

  services.udev.packages = [ pkgs.stlink ];

  home-manager.users.alukard.services.udiskie.enable = true;

  services.upower.enable = true;

  systemd.services.systemd-udev-settle.enable = false;

  # Enable zram, disable zswap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 60;
    numDevices = 1;
  };
  boot.kernelParams = [ "zswap.enabled=0" ];
}
