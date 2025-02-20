{ inputs, config, pkgs, lib, ... }:
let
  zfs_arc_max = toString (3 * 1024 * 1024 * 1024);
in {
  # CachyOS kernel
  imports = [ inputs.chaotic.nixosModules.default ];

  boot = {
    # zfs.package = pkgs.zfs_cachyos;
    # kernelPackages = pkgs.linuxPackages_cachyos-hardened;
    # kernelPackages = pkgs.linuxPackages_cachyos-server;
    # kernelPackages = pkgs.linuxPackages_hardened;
    # kernelPackages = pkgs.linuxPackages;
    # kernelPackages = pkgs.linuxPackages_xanmod;

    initrd = {
      luks.devices = {
        # "cryptboot" = {
        #   allowDiscards = true;
        #   bypassWorkqueues = config.deviceSpecific.isSSD;
        #   keyFile = "/keyfile0.bin";
        # };
        "cryptroot" = {
          allowDiscards = true;
          bypassWorkqueues = config.deviceSpecific.isSSD;
          keyFile = "/keyfile0.bin";
        };
        "crypt-nas" = {
          device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC1A7CWN";
          keyFile = "/nas_keyfile0.bin";
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
        "nas_keyfile0.bin" = "/etc/secrets/nas_keyfile0.bin";
      };
      supportedFilesystems = [ "zfs" ];
      systemd.enable = true;
    };
    loader = {
      efi.canTouchEfiVariables = false;
      efi.efiSysMountPoint = "/efi";
      generationsDir.copyKernels = true;
      grub = {
        enable = true;
        enableCryptodisk = true;
        device = "nodev";
        copyKernels = true;
        efiInstallAsRemovable = true;
        efiSupport = true;
        zfsSupport = true;
        useOSProber = false;
      };
    };
    kernelModules = [ "tcp_bbr" "veth" "nfsv4" ];
    kernelParams = [
      "zfs.zfs_arc_max=${zfs_arc_max}"
      "zswap.enabled=0"
      "scsi_mod.use_blk_mq=1"
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
      "vm.overcommit_memory" = lib.mkForce 1;
    };

    supportedFilesystems = [ "nfs4" ];
    zfs.extraPools = [ "bpool" "rpool" "nas-pool" ];
  };

  networking.hostId = "a9408846";

  # Impermanence
  persist = {
    enable = true;
    cache.clean.enable = true;
  };
  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  # boot.initrd.systemd.services.rollback = {
  #   description = "Rollback zfs to a pristine state on boot";
  #   wantedBy = [ "initrd.target" ];
  #   after = [ "zfs-import-rpool.service" ];
  #   before = [ "sysroot.mount" ];
  #   path = [ config.boot.zfs.package ];
  #   unitConfig.DefaultDependencies = "no";
  #   serviceConfig.Type = "oneshot";
  #   script = ''
  #     zfs rollback -r rpool/nixos/root@empty && echo "  >>> rollback root <<<"
  #     zfs rollback -r rpool/user/home@empty && echo "  >>> rollback home <<<"
  #   '';
  # };
}
