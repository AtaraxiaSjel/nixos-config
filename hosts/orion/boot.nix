{ pkgs, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # services.scx.enable = true;
  # services.scx.scheduler = "scx_bpfland";

  networking.hostId = "a9408846";

  boot = {
    kernelPackages = pkgs.linuxPackages_lqx;
    zfs.package = pkgs.zfs;

    zfs.devNodes = "/dev/disk/by-id";
    zfs.extraPools = [ "nas-pool" ];

    initrd = {
      luks.devices = {
        "crypt-nas" = {
          device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC1A7CWN";
          keyFile = "/nas_keyfile0.bin";
        };
      };
      secrets = {
        "/nas_keyfile0.bin" = "/etc/secrets/nas_keyfile0.bin";
      };
      supportedFilesystems = [ "zfs" ];
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
