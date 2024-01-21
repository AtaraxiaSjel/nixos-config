{ config, pkgs, lib, ... }:
let
  zfs_arc_max = toString (3 * 1024 * 1024 * 1024);
in {
  boot = {
    # extraModprobeConfig = ''
    #   options zfs metaslab_lba_weighting_enabled=0
    # '';
    zfs.forceImportAll = lib.mkForce false;
    loader.efi.canTouchEfiVariables = false;
    loader.efi.efiSysMountPoint = "/efi";
    loader.generationsDir.copyKernels = true;
    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
      zfsSupport = true;
      efiInstallAsRemovable = true;
      copyKernels = true;
    #   # extraPrepareConfig = ''
    #   # '';
    };
    initrd = {
      luks.devices = {
        "cryptboot" = {
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = config.deviceSpecific.isSSD;
          fallbackToPassword = true;
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
      "kvm.report_ignored_msrs=0"
      "rd.systemd.show_status=auto"
      "rd.udev.log_priority=3"
    ];
    kernel.sysctl = {
      "vm.swappiness" = 80;
      "vm.vfs_cache_pressure" = 200;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 40;
      "vm.page-cluster" = 0;
      "vm.overcommit_memory" = 1;

      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };
}
