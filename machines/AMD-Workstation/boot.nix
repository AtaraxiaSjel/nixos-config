{ config, pkgs, lib, ... }:
let
  zfs_arc_max = toString (6 * 1024 * 1024 * 1024);
in {
  boot = {
    initrd = {
      supportedFilesystems = [ "zfs" ];
      luks.devices = {
        "cryptroot" = {
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = true;
          fallbackToPassword = true;
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
      };
    };

    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        copyKernels = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = false;
        zfsSupport = true;
        # efiInstallAsRemovable = true;
        # theme = pkgs.;
      };
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      generationsDir.copyKernels = true;
    };

    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelPackages = pkgs.linuxPackages_lqx;
    kernelParams = [
      "zfs.metaslab_lba_weighting_enabled=0"
      "zfs.zfs_arc_max=${zfs_arc_max}"
    ];
    tmpOnTmpfs = true;
    tmpOnTmpfsSize = "32G";

    supportedFilesystems = [ "ntfs" ];
  };

  persist = {
    enable = true;
    cache.clean.enable = true;
    # state.files = [
    #   "/etc/machine-id"
    #   "/etc/NIXOS"
    # ];
  };

  fileSystems."/" = lib.mkForce {
    device = "none";
    options = [ "defaults" "size=4G" "mode=755" ];
    fsType = "tmpfs";
  };

  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@empty
    zfs rollback -r rpool/user/home@empty
  '';
}