{ ... }: {
  autoinstall.Dell-Laptop = {
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    encryption.encryptBoot = false;
    encryption.encryptRoot = true;
    encryption.passwordFile = "/home/nixos/pass";
    encryption.argonIterTime = "4000";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_250GB_S3ESNX0K159868B";
    partitioning.nullifyDisk = false;
    partitioning.createBootPool = true;
    swapPartition.enable = true;
    swapPartition.size = "8GiB";
    efiMountPoint = "/efi";
    bootSize = "2G";
    zfsOpts.ashift = 13;
    zfsOpts.bootPoolReservation = "128M";
    zfsOpts.rootPoolReservation = "12G";
    persist.enable = true;
  };
}
