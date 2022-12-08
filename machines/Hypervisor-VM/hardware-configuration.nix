# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "virtio_pci" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/nixos/root";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/home" =
    { device = "rpool/user/home";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/persistent" =
    { device = "rpool/persistent/impermanence";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/etc/secrets" =
    { device = "rpool/persistent/secrets";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/nix" =
    { device = "rpool/persistent/nix";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/log" =
    { device = "rpool/persistent/log";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "rpool/persistent/docker";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/media/bittorrent" =
    { device = "rpool/persistent/bittorrent";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/media/libvirt" =
    { device = "rpool/persistent/libvirt";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot" =
    { device = "bpool/nixos/boot";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/D76A-09CE";
      fsType = "vfat";
    };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/d92c3ab0-8205-49fb-99ab-abe98a943d39";
      randomEncryption.enable = true;
      randomEncryption.allowDiscards = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.hostId = "41d97526";
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.luks.devices."cryptboot".device = "/dev/disk/by-partuuid/45979da9-33b7-4c7a-8eaf-005e642a974d";
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partuuid/74d318d9-1349-4281-8bbd-82ac718f052c";
}
