# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/43364c66-885f-4fc3-8138-95bd2d0d8d36";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  boot.initrd.luks.devices."cryptnixos".device = "/dev/disk/by-uuid/c9a08672-55fd-42d7-8903-c6ea06462c49";

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/43364c66-885f-4fc3-8138-95bd2d0d8d36";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/43364c66-885f-4fc3-8138-95bd2d0d8d36";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix/store" =
    { device = "/dev/disk/by-uuid/43364c66-885f-4fc3-8138-95bd2d0d8d36";
      fsType = "btrfs";
      options = [ "subvol=@nix-store" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7294-A273";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
