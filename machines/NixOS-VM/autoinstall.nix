{ lib, ... }: {
  autoinstall.NixOS-VM = {
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-2";
    swapPartition.enable = true;
    swapPartition.size = "4GiB";
    zfsOpts.ashift = 13;
    persist.enable = true;
  };
}
