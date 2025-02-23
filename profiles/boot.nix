{ lib, pkgs, config, ... }:
with config.deviceSpecific; {
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    memoryPercent = 150; # around 50% of memory
  };

  persist.state.files = [ "/etc/machine-id" ];

  services.earlyoom = {
    enable = devInfo.ram < 16;
    freeMemThreshold = 5;
    freeSwapThreshold = 100;
  };

  services.fstrim = lib.mkIf (devInfo.fileSystem != "zfs") {
    enable = isSSD;
    interval = "weekly";
  };

  services.zfs = lib.mkIf (devInfo.fileSystem == "zfs") {
    autoScrub.enable = true;
    autoScrub.interval = "monthly";
    trim.enable = isSSD;
    trim.interval = "weekly";
  };

  boot = {
    loader = {
      timeout = lib.mkForce 4;
      systemd-boot.enable = lib.mkDefault
        pkgs.hostPlatform.system == "x86_64-linux";
    };

    kernelParams =
      [ "zswap.enabled=0" "scsi_mod.use_blk_mq=1" "nofb" ]
      ++ lib.optionals (pkgs.hostPlatform.system == "x86_64-linux") [
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "pti=off"
        "spectre_v2=off"
        "kvm.ignore_msrs=1"
        "kvm.report_ignored_msrs=0"
      ];

    kernelPackages = lib.mkDefault pkgs.linuxPackages_lqx;

    consoleLogLevel = 3;
    kernel.sysctl = if config.zramSwap.enable then {
      "vm.swappiness" = 100;
      "vm.vfs_cache_pressure" = 500;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
      "vm.page-cluster" = 0;
    } else {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };

    tmp.cleanOnBoot = !config.boot.tmp.useTmpfs;
    zfs.forceImportAll = lib.mkDefault false;
    swraid.enable = false;
  };
}
