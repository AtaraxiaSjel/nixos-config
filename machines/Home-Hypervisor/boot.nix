{ config, pkgs, lib, ... }:
let
  zfs_arc_max = toString (2 * 1024 * 1024 * 1024);
in {
  boot = {
    # extraModprobeConfig = ''
    #   options zfs metaslab_lba_weighting_enabled=0
    # '';
    zfs.forceImportAll = lib.mkForce false;
    loader.efi.canTouchEfiVariables = false;
    loader.efi.efiSysMountPoint = "/boot/efi";
    loader.generationsDir.copyKernels = true;
    loader.grub = {
      enable = true;
      device = "nodev";
      version = 2;
      efiSupport = true;
      enableCryptodisk = true;
      zfsSupport = true;
      efiInstallAsRemovable = true;
      copyKernels = true;
    #   # extraPrepareConfig = ''
    #   # '';
    };
    initrd = {
      # availableKernelModules = [ "tg3" ]; # for dell-laptop
      # postMountCommands = ''
      # '';
      luks.devices = {
        "cryptboot" = {
          preLVM = true;
          keyFile = "/keyfile0.bin";
          # keyFileSize = 4096;
          # keyFile = "/dev/disk/by-path/pci-0000:00:1f.2-ata-2.0";
          # keyFile = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00005";
          allowDiscards = true;
          bypassWorkqueues = config.deviceSpecific.isSSD;
          fallbackToPassword = true;
          # postOpenCommands = "";
          # preOpenCommands = "";
        };
        "cryptroot" = {
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = config.deviceSpecific.isSSD;
          fallbackToPassword = true;
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
      };
    };
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelModules = [ "tcp_bbr" "veth" ];
    kernelParams = [
      # "zfs.metaslab_lba_weighting_enabled=0"
      "zfs.zfs_arc_max=${zfs_arc_max}"
      "zswap.enabled=0"
      "quiet"
      "scsi_mod.use_blk_mq=1"
      "modeset"
      "nofb"
      "pti=off"
      "spectre_v2=off"
      "kvm.ignore_msrs=1"
      "rd.systemd.show_status=auto"
      "rd.udev.log_priority=3"
    ];
    kernel.sysctl = {
      "kernel.sysrq" = false;
      "net.core.default_qdisc" = "sch_fq_codel";
      "net.ipv4.conf.all.accept_source_route" = false;
      "net.ipv4.icmp_ignore_bogus_error_responses" = true;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_rfc1337" = true;
      "net.ipv4.tcp_syncookies" = true;
      "net.ipv6.conf.all.accept_source_route" = false;
      # disable ipv6
      "net.ipv6.conf.all.disable_ipv6" = true;
      "net.ipv6.conf.default.disable_ipv6" = true;
    };
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
    # cleanTmpDir = true;
  };
}