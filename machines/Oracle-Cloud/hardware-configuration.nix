{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/C8C5-C634"; fsType = "vfat"; };
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda3"; fsType = "xfs"; };
  swapDevices = [ {
      device = "/dev/disk/by-partuuid/d4aa8434-9803-45ac-9983-07e10e1409b4";
      randomEncryption.enable = true;
  } ];
}