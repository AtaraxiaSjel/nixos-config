{ ... }: {
  autoinstall.AMD-Workstation = {
#     debug = true;
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    encryption.encryptBoot = false;
    encryption.encryptRoot = true;
    encryption.passwordFile = "/home/nixos/pass";
    encryption.argonIterTime = "4000";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-id/nvme-XPG_GAMMIX_S11_Pro_2K342L2BBNUY";
    partitioning.nullifyDisk = false;
    partitioning.emptySpace = "100GiB";
    partitioning.createBootPool = true;
    swapPartition.enable = true;
    swapPartition.size = "16GiB";
    efiMountPoint = "/efi";
    zfsOpts.ashift = 13;
    zfsOpts.bootPoolReservation = "256M";
    zfsOpts.rootPoolReservation = "45G";
    persist.enable = true;
  };
}
