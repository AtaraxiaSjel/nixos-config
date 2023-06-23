{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/34c39dc8-07e8-4dd0-9c74-462d43c874d0";
    fsType = "btrfs";
    options = [ "subvol=rootfs" "compress=zstd" "noatime" "autodefrag" "ssd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partuuid/34c39dc8-07e8-4dd0-9c74-462d43c874d0";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" "autodefrag" "ssd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partuuid/a9bc6629-2e9b-46e8-b482-aea8651d1949";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partuuid/34c39dc8-07e8-4dd0-9c74-462d43c874d0";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd" "noatime" "autodefrag" "ssd" ];
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/a460e7c7-3005-4516-9a8e-f751082b8bb6";
    randomEncryption.enable = true;
    randomEncryption.allowDiscards = true;
    priority = 0;
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
