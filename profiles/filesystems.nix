{ pkgs, lib, config, ... }:
with rec {
  inherit (config) deviceSpecific secrets device;
};
with deviceSpecific;
{
  secrets.samba.services = [];
  secrets.files-veracrypt = {};

  environment.etc.crypttab = lib.mkIf (device == "AMD-Workstation") {
    text = ''
      files-veracrypt /dev/disk/by-partuuid/15fa11a1-a6d8-4962-9c03-74b209d7c46a /var/secrets/files-veracrypt tcrypt-veracrypt
    '';
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
    # "/media/files" = if (device == "AMD-Workstation") then {
    "/media/files" = lib.mkIf (device == "AMD-Workstation") {
      # Samba host
      fsType = "ntfs";
      device = "/dev/mapper/files-veracrypt";
      options = [
        # "noatime"
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbuser.gid}"
      ];
    };
    # } else {
      # Linux samba
      # fsType = "cifs";
      # device = "//192.168.0.100/files";
      # options = [
      #   "credentials=${secrets.samba.decrypted}"
      #   "uid=${toString config.users.users.alukard.uid}"
      #   "gid=${toString config.users.groups.users.gid}"
      #   "vers=3.0"
      #   "nofail"
      #   "noauto"
      #   "x-systemd.automount"
      #   "x-systemd.mount-timeout=5"
      #   "_netdev"
      # ];
    # };
  };
}
