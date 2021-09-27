{ pkgs, lib, config, ... }:
with rec {
  inherit (config) deviceSpecific secrets device;
};
with deviceSpecific;
{
  secrets.samba = {
    services = [ ];
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
        "gid=${toString config.users.groups.smbuser.gid}"
      ];
    };
    "/media/data" = if (device == "AMD-Workstation") then {
      # Samba host
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/a61ac8ea-53b9-462f-8a93-a5c07b131209";
      options = [
        # "noatime"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbuser.gid}"
      ];
    } else {
      # Linux samba
      fsType = "cifs";
      device = "//192.168.0.100/data";
      options = [
        "credentials=${secrets.samba.decrypted}"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "vers=3.0"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.mount-timeout=5"
        "_netdev"
      ];
    };
    "/media/files" = if (device == "AMD-Workstation") then {
      # Samba host
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/8a1d933c-302b-4e62-b9af-a45ecd05777f";
      options = [
        # "noatime"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbuser.gid}"
      ];
    } else {
      # Linux samba
      fsType = "cifs";
      device = "//192.168.0.100/files";
      options = [
        "credentials=${secrets.samba.decrypted}"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "vers=3.0"
        "nofail"
        "noauto"
        "x-systemd.automount"
        "x-systemd.mount-timeout=5"
        "_netdev"
      ];
    };

    "/media/local/files" = lib.mkIf (device == "Dell-Laptop") {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/506c04f2-ecb1-4747-843a-576163828373";
      options = [
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "dmask=027"
        "fmask=137"
        "rw"
      ];
    };
    "/media/local/sys" = lib.mkIf (device == "Dell-Laptop") {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/bf5cdb93-fce3-4b02-8ba5-e43483a3a061";
      options = [
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "dmask=027"
        "fmask=137"
        "ro"
      ];
    };

    # Music folder
    # TODO: FIXIT
    "/home/alukard/Music" = {
      fsType = "none";
      device = "/media/files/Music";
      depends = [ "/media/files" ];
      options = [
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.users.gid}"
        "bind"
        "nofail"
        "_netdev"
      ];
    };
  };
}
