# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/be70ce11-d42d-4b5b-ba03-32ffd8e1491f";
      fsType = "btrfs";
      options = [ "subvol=nixos" "compress-force=zstd" "noatime" "autodefrag" "ssd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/be70ce11-d42d-4b5b-ba03-32ffd8e1491f";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress-force=zstd" "noatime" "autodefrag" "ssd" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/be70ce11-d42d-4b5b-ba03-32ffd8e1491f";
      fsType = "btrfs";
      options = [ "subvol=home" "compress-force=zstd" "noatime" "autodefrag" "ssd" ];
    };

  fileSystems."/var" =
    { device = "/dev/disk/by-uuid/be70ce11-d42d-4b5b-ba03-32ffd8e1491f";
      fsType = "btrfs";
      options = [ "subvol=var" "compress-force=zstd" "noatime" "autodefrag" "ssd" ];
    };

  fileSystems."/media/bittorrent" =
    { device = "/dev/disk/by-uuid/be70ce11-d42d-4b5b-ba03-32ffd8e1491f";
      fsType = "btrfs";
      options = [ "subvol=bittorrent" "nodatacow" "ssd" ];
    };

  fileSystems."/media/libvirt" =
    { device = "/dev/disk/by-uuid/be70ce11-d42d-4b5b-ba03-32ffd8e1491f";
      fsType = "btrfs";
      options = [ "subvol=libvirt" "nodatacow" "ssd" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/948B-11EC";
      fsType = "vfat";
    };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/417966a4-f0f1-4cf4-8954-f30007268a09";
      randomEncryption.enable = true;
    }
  ];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
  networking.hostId = "a517ac4a";
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];
}
