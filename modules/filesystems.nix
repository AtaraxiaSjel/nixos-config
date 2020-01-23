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
    "/media/data" = if isHost then {
      # Samba host
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/944f923d-cf08-4752-bf3f-8aa8e0190260";
      options = [
        # "ro"
        # "noatime"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbgrp.gid}"
      ];
    } else {
      # Linux samba
      fsType = "cifs";
      device = "//192.168.0.100/data";
      options = [
        "ro"
        "user=${secrets.linux-samba.user}"
        "password=${secrets.linux-samba.password}"
        # "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
    "/media/files" = if isHost then {
      # Samba host
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/8a1d933c-302b-4e62-b9af-a45ecd05777f";
      options = [
        # "ro"
        # "noatime"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbgrp.gid}"
      ];
    } else {
      # Linux samba
      fsType = "cifs";
      device = "//192.168.0.100/files";
      options = [
        "user=${secrets.linux-samba.user}"
        "password=${secrets.linux-samba.password}"
        # "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
    # Samba Windows
    "/media/windows/files" = lib.mkIf (!isHost) {
      fsType = "cifs";
      device = "//192.168.0.100/Files";
      options = [
        "user=${secrets.windows-samba.user}"
        "password=${secrets.windows-samba.password}"
        # "nofail"
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
        # "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
  };
  swapDevices = [
    {
      device = if device == "AMD-Workstation" then
          "/dev/disk/by-partuuid/3c4f9305-ad40-4ed3-b568-f1559f1c845a"
        else if device == "Dell-Laptop" then
          "/dev/disk/by-partuuid/e979f198-37c4-4a86-8138-e148c3d78447"
        else if device == "NixOS-VM" then
          "/dev/disk/by-partuuid/4caf1e45-2f1c-4cb2-a914-f2e90961503a"
        else
          "";
      randomEncryption.enable = true;
    }
  ];
}