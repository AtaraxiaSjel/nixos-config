{ pkgs, lib, config, ... }:
with rec {
  inherit (config) deviceSpecific secrets;
};
with deviceSpecific;
# let
#   wgEnabled = config.secrets.wireguard.${config.device}.enable;
# in
{

  services.zfs = {
    trim.enable = true;
    trim.interval = "weekly";
    autoScrub.enable = true;
    autoScrub.interval = "weekly";
    autoSnapshot = {
      enable = true;
      frequent = 8;
      hourly = 8;
      daily = 4;
      weekly = 2;
      monthly = 2;
    };
  };

  fileSystems = {
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
        "user=${secrets.linux-samba.user}"
        "password=${secrets.linux-samba.password}"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "vers=3.0"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.mount-timeout=15"
        "_netdev"
      ];
      # ] ++ lib.optionals wgEnabled [
      #   "x-systemd.after=wg-quick-wg0.service"
      # ];
    };
    "/media/files" = if isHost then {
      # Samba host

      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/8a1d933c-302b-4e62-b9af-a45ecd05777f";
      options = [
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
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "vers=3.0"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.mount-timeout=15"
        "_netdev"
      ];
      # ] ++ lib.optionals wgEnabled [
      #   "x-systemd.after=wg-quick-wg0.service"
      # ];
    };
    # Samba Windows
    "/media/windows/files" = lib.mkIf (!isHost) {
      fsType = "cifs";
      device = "//192.168.0.100/Files";
      options = [
        "user=${secrets.windows-samba.user}"
        "password=${secrets.windows-samba.password}"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "vers=3.0"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.mount-timeout=15"
        "_netdev"
      ];
      # ] ++ lib.optionals wgEnabled [
      #   "x-systemd.after=wg-quick-wg0.service"
      # ];
    };
    "/media/windows/data" = lib.mkIf (!isHost) {
      fsType = "cifs";
      device = "//192.168.0.100/Data";
      options = [
        "user=${secrets.windows-samba.user}"
        "password=${secrets.windows-samba.password}"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "vers=3.0"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.mount-timeout=15"
        "_netdev"
      ];
      # ] ++ lib.optionals wgEnabled [
      #   "x-systemd.after=wg-quick-wg0.service"
      # ];
    };

    # Music folder
    # TODOL FIXIT
    "/home/alukard/Music" = {
      fsType = "none";
      device = "/media/windows/files/Music";
      options = [
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "bind"
        "nofail"
        "x-systemd.requires-mounts-for=media-windows-files.mount"
        "_netdev"
      ];
    };
  };
}
