{ lib, pkgs, config, ... }:
with config.deviceSpecific; {
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 60;
    numDevices = 1;
  };

  persist.state.files = [ "/etc/machine-id" ];

  boot = if !isServer && !isISO then {
    loader = {
      timeout = lib.mkForce 4;
      systemd-boot.enable = pkgs.system == "x86_64-linux";
    };

    kernelParams = [ "zswap.enabled=0" "quiet" "scsi_mod.use_blk_mq=1" "modeset" "nofb" ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "pti=off"
        "spectre_v2=off"
        "kvm.ignore_msrs=1"
      ];

    kernelPackages = pkgs.linuxPackages_lqx;

    supportedFilesystems = [ "ntfs" ];

    extraModprobeConfig = lib.mkIf (config.device == "AMD-Workstation") ''
      options snd slots=snd_virtuoso,snd_usb_audio
    '';

    consoleLogLevel = 3;
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };

    cleanTmpDir = true;
    zfs.forceImportAll = false;
  } else if isServer then {
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelModules = [ "tcp_bbr" ];
    kernelParams = [
      "zswap.enabled=0"
      "quiet"
      "scsi_mod.use_blk_mq=1"
      "modeset"
      "nofb"
      "pti=off"
      "spectre_v2=off"
      "kvm.ignore_msrs=1"
    ];
    kernel.sysctl = {
      "kernel.sysrq" = false;
      "net.core.default_qdisc" = "cake";
      "net.ipv4.conf.all.accept_source_route" = false;
      "net.ipv4.icmp_ignore_bogus_error_responses" = true;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_rfc1337" = true;
      "net.ipv4.tcp_syncookies" = true;
      "net.ipv6.conf.all.accept_source_route" = false;
    };
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
    cleanTmpDir = true;
    zfs.forceImportAll = false;
  } else {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    kernelParams = lib.mkForce [ "zswap.enabled=0" ];
    supportedFilesystems = lib.mkForce [ "ext4" "vfat" "btrfs" "ntfs" ];
    zfs.forceImportAll = false;
  };
}
