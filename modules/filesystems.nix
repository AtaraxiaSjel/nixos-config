{ pkgs, lib, config, ... }:
with rec {
  inherit (config) device deviceSpecific secrets;
};
with deviceSpecific; {
  boot.resumeDevice = "/dev/mapper/cryptswap";
  fileSystems = {
    "/" = {
      options = if isSSD then
        [ "ssd" "noatime" "compress=zstd" ]
      else
        [ "noatime" "compress=zstd" ];
    };
    "/.snapshots" = {
      options = if isSSD then
        [ "ssd" "noatime" "compress=zstd" ]
      else
        [ "noatime" "compress=zstd" ];
    };
    "/home" = {
      options = if isSSD then
        [ "ssd" "noatime" "compress=zstd" ]
      else
        [ "noatime" "compress=zstd" ];
    };
    "/nix/store" = {
      options = if isSSD then
        [ "ssd" "noatime" "compress=zstd" ]
      else
        [ "noatime" "compress=zstd" ];
    };

    "/shared/nixos" = lib.mkIf isVM {
      fsType = "vboxsf";
      device = "shared";
      options = [
        "rw"
        "nodev"
        "relatime"
        "nofail"
        "dmode=0755"
        "fmode=0644"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbgrp.gid}"
      ];
    };
    "/media/windows/files" = lib.mkIf (!isHost) {
      fsType = "cifs";
      device = "//192.168.0.100/Files";
      options = [
        "user=${secrets.windows-samba.user}"
        "password=${secrets.windows-samba.password}"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
    "/media/windows/data" = lib.mkIf (!isHost) {
      fsType = "cifs";
      device = "//192.168.0.100/Data";
      options = [
        "ro"
        "user=${secrets.windows-samba.user}"
        "password=${secrets.windows-samba.password}"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
  };
  swapDevices = [
    {
      device = "/dev/mapper/cryptswap";
      encrypted = {
        enable = true;
        keyFile = "/mnt-root/root/swap.key";
        label = "cryptswap";
        blkDev = if device == "Dell-Laptop" then
          "/dev/disk/by-uuid/c623d956-d0ea-4626-8e0c-5092bbbf3b0c"
        else
          "";
      };
    }
  ];
}