{ lib, ... }: {
  autoinstall = {
    hostname = "Arch-Builder-VM";
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM0003";
    partitioning.nullifyDisk = false;
    swapPartition.enable = true;
    swapPartition.size = "8GiB";
    zfsOpts.ashift = 13;
    persist.enable = true;
  };
}
