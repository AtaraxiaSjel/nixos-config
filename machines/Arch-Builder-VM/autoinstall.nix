{ ... }: {
  autoinstall.Arch-Builder-VM = {
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00003";
    partitioning.nullifyDisk = false;
    partitioning.createBootPool = true;
    swapPartition.enable = true;
    swapPartition.size = "2GiB";
    efiMountPoint = "/efi";
    bootSize = "512MiB";
    efiSize = "128MiB";
    zfsOpts.ashift = 13;
    persist.enable = false;
  };
}
