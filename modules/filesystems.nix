{ pkgs, lib, config, ... }: {
  fileSystems = {
    "/" = {
      options = if config.deviceSpecific.isSSD then
        [ "ssd" "noatime" "compress=zstd" ]
      else
        [ "noatime" "compress=zstd" ];
    };
    "/shared/nixos" = lib.mkIf config.deviceSpecific.isVM {
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
        # "gid=${toString config.users.groups.users.gid}"
        "gid=${toString config.users.groups.smbgrp.gid}"
      ];
    };
  };

  # mount swap
  swapDevices = [
    { label = "swap"; }
  ];
}