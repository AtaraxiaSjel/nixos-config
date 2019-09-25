{ pkgs, lib, config, ... }:
with rec {
  inherit (config) device deviceSpecific secrets;
};
with deviceSpecific; {
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
      device = if device == "Dell-Laptop" then
          "/dev/disk/by-partuuid/2de40bc4-a91c-4c89-a2cd-cbf34a0adf01"
        else if device == "NixOS-VM" then
          "/dev/disk/by-partuuid/afa18996-0fbc-448d-86ba-acf3f046671d"
        else
          "";
      randomEncryption.enable = true;
    }
  ];
}