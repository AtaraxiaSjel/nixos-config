{ ... }: {
  autoinstall."Home-Hypervisor" = {
    debug = false;
    mainuser = "ataraxia";
    flakesPath = "/home/nixos/nixos-config";
    encryption.encryptBoot = true;
    encryption.encryptRoot = true;
    encryption.passwordFile = "/home/nixos/pass";
    encryption.argonIterTime = "4000";
    partitioning.useEntireDisk = true;
    partitioning.disk = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S5Y1NJ1R160554B";
    partitioning.nullifyDisk = false;
    swapPartition.enable = true;
    swapPartition.size = "8GiB";
    zfsOpts.ashift = 13;
    zfsOpts.bootPoolReservation = "256M";
    zfsOpts.rootPoolReservation = "25G";
    persist.enable = true;
    oldUefi = true;
  };
}
