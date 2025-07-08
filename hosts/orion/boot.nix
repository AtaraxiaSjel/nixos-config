{ pkgs, ... }:
{
  services.scx.enable = true;
  services.scx.scheduler = "scx_bpfland";

  networking.hostId = "a9408846";

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos-server;
    zfs.package = pkgs.zfs_cachyos;
    zfs.devNodes = "/dev/disk/by-id";

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        copyKernels = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = false;
        zfsSupport = true;
      };
      efi.efiSysMountPoint = "/efi";
      efi.canTouchEfiVariables = true;
    };

    kernelModules = [
      "tcp_bbr"
      "veth"
      "nfsv4"
    ];
    kernelParams = [
      "scsi_mod.use_blk_mq=1"
      "pti=off"
      "spectre_v2=off"
    ];
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;
      "vm.overcommit_memory" = 1;
    };

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "100%";
    tmp.tmpfsHugeMemoryPages = "within_size";

    supportedFilesystems = [ "zfs" ];
  };
}
