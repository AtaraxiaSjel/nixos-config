# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/nixos/root";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/home" =
    { device = "rpool/user/home";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/persist" =
    { device = "rpool/persistent/impermanence";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/srv" =
    { device = "rpool/persistent/servers";
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

  fileSystems."/var/lib/podman" =
    { device = "rpool/persistent/podman";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/lib/nixos-containers" =
    { device = "rpool/persistent/nixos-containers";
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
    { device = "/dev/disk/by-uuid/C5F3-4271";
      fsType = "vfat";
    };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/4623124f-05e6-4d55-8fe8-6cd9a904fd72";
      randomEncryption.enable = true;
      randomEncryption.allowDiscards = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    networking.hostId = "a9408846";
    boot.zfs.devNodes = "/dev/disk/by-id";
    boot.supportedFilesystems = [ "zfs" ];
    boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partuuid/465cbfbb-73b8-4129-9904-9fabcc5db368";
    boot.initrd.luks.devices."cryptboot".device = "/dev/disk/by-partuuid/74f2b810-c7ff-471d-9829-7a3ef05c8c0e";
}