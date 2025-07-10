{ pkgs, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # services.scx.enable = true;
  # services.scx.scheduler = "scx_bpfland";

  networking.hostId = "a9408846";

  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    # zfs.package = pkgs.zfs_unstable;
    zfs.devNodes = "/dev/disk/by-id";
    zfs.extraPools = [ "nas-pool" ];

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
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];
    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;
      "vm.overcommit_memory" = mkForce 1;
    };

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "100%";
    tmp.tmpfsHugeMemoryPages = "within_size";

    supportedFilesystems = [ "zfs" ];
  };
}
