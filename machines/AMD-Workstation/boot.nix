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
        device = "nodev";
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
        zfsSupport = true;
#         efiInstallAsRemovable = true;
        copyKernels = true;
      };
      systemd-boot = {
        enable = lib.mkForce false;
        editor = false;
        configurationLimit = 10;
#         graceful = true;
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      generationsDir.copyKernels = true;
    };

#     binfmt.emulatedSystems = [ "aarch64-linux" ];
#     kernelPackages = lib.mkForce pkgs.linuxPackages_lqx;
    kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [
      "zfs.metaslab_lba_weighting_enabled=0"
      "zfs.zfs_arc_max=${zfs_arc_max}"
    ];
    tmpOnTmpfs = true;
    tmpOnTmpfsSize = "32G";

#     zfs.extraPools = [ "rpool" ];
  };

  persist = {
    enable = true;
    cache.clean.enable = false;
    state.files = [
#       "/etc/machine-id"
      "/etc/NIXOS"
    ];
  };

  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@empty
    zfs rollback -r rpool/user/home@empty
  '';
}
