{ lib, pkgs, ... }:
{
  fileSystems."/" = lib.mkForce {
    device = "none";
    options = [
      "defaults"
      "size=4G"
      "mode=755"
    ];
    fsType = "tmpfs";
  };

  services.scx.enable = true;
  services.scx.scheduler = "scx_rustland";

  networking.hostId = "b06ca84a";

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos;
    zfs.package = pkgs.zfs_cachyos;
    zfs.devNodes = "/dev/disk/by-id";

    blacklistedKernelModules = [ "psmouse" ];
    kernelParams = [ "mem_sleep_default=deep" ];

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        copyKernels = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = false;
        zfsSupport = true;
        gfxmodeEfi = "1920x1080";
      };
      efi.efiSysMountPoint = "/efi";
      efi.canTouchEfiVariables = true;
    };

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "100%";
    tmp.tmpfsHugeMemoryPages = "within_size";

    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
  };
}
