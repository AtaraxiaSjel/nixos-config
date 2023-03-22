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
      # kernelModules = [
      #   "mmc_core" "mmc_block" "sdhci" "sdhci-pci"
      #   "vfat" "nls_cp437" "nls_iso8859_1"
      # ];
      # postDeviceCommands = let
      #   SDUUID = "E54A-5461";
      # in pkgs.lib.mkBefore ''
      #   mkdir -m 0755 -p /key
      #   sleep 2 # To make sure the usb key has been loaded
      #   mount -n -t vfat -o ro `findfs UUID=${SDUUID}` /key
      # '';
      # availableKernelModules = [ "tg3" ]; # for dell-laptop
      # postMountCommands = ''
      # '';
      luks.devices = {
        "cryptboot" = {
          # preLVM = false;
          preLVM = true;
          # keyFile = "/key/keyfile0";
          keyFile = "/keyfile0.bin";
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
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
    # cleanTmpDir = true;
  };
}
