{ config, pkgs, lib, ... }:
let
  zfs_arc_max = toString (6 * 1024 * 1024 * 1024);
in {
  boot = {
    zfs.package = pkgs.zfs_unstable;
    kernelPackages = pkgs.linuxPackages_xanmod_latest;

    initrd = {
      supportedFilesystems = [ "zfs" ];
      luks.devices = {
        "cryptroot" = {
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
      };
    };

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        copyKernels = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = false;
        zfsSupport = true;
        gfxmodeEfi = "2560x1440";
        # efiInstallAsRemovable = true;
      };
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      generationsDir.copyKernels = true;
    };

    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelParams = [
      "zfs.metaslab_lba_weighting_enabled=0"
      "zfs.zfs_arc_max=${zfs_arc_max}"
      "amd_pstate=active"
      "retbleed=off" # big performance impact
      "amdgpu.ignore_min_pcap=1"
    ];
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;
    };
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "32G";

    supportedFilesystems = [ "ntfs" ];
  };

  persist = {
    enable = true;
    cache.clean.enable = true;
  };

  fileSystems."/" = lib.mkForce {
    device = "none";
    options = [ "defaults" "size=4G" "mode=755" ];
    fsType = "tmpfs";
  };

  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback zfs to a pristine state on boot";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    path = [ config.boot.zfs.package ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/nixos/root@empty && echo "  >>> rollback root <<<"
      zfs rollback -r rpool/user/home@empty && echo "  >>> rollback home <<<"
    '';
  };
}
