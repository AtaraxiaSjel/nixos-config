{ lib, ... }: {
  autoinstall.Arch-Builder-VM = {
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-path/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-1";
    partitioning.nullifyDisk = false;
    swapPartition.enable = true;
    swapPartition.size = "4GiB";
    zfsOpts.ashift = 13;
    persist.enable = true;
  };
}
