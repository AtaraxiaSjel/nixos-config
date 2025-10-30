{ lib, ... }:
{
  ataraxia.defaults.boot.cachyosKernel = true;

  services.scx.enable = true;
  services.scx.scheduler = "scx_rustland";

  networking.hostId = "b06ca84a";

  boot = {
    zfs.devNodes = "/dev/disk/by-id";

    blacklistedKernelModules = [ "psmouse" ];
    kernelParams = [ "mem_sleep_default=deep" ];

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "100%";
    tmp.tmpfsHugeMemoryPages = "within_size";

    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
  };

  fileSystems."/" = lib.mkForce {
    device = "none";
    options = [
      "defaults"
      "size=4G"
      "mode=755"
    ];
    fsType = "tmpfs";
  };
}
