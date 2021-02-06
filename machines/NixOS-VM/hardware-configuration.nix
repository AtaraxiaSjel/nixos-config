# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "xhci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "rpool/system/var";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/user/home";
      fsType = "zfs";
    };

  fileSystems."/home/alukard/.libvirt" =
    { device = "rpool/local/libvirt";
      fsType = "zfs";
    };

  fileSystems."/bittorrent" =
    { device = "rpool/local/bittorrent";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9D49-7087";
      fsType = "vfat";
    };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/6e22eab7-2e47-4108-bd97-76e3bdc2c6c1";
      randomEncryption.enable = true;
    }
  ];

  virtualisation.virtualbox.guest.enable = true;
  networking.hostId = "524df2e8";
  boot.zfs.devNodes = "/dev/disk/by-partuuid/37beaf62-685a-43b2-95b2-e777a77993e1";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "zfs.zfs_arc_max=1073741824" ];
}
