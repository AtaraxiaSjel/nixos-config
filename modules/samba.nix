{ config, lib, pkgs, ... }:
with rec {
  inherit (config) deviceSpecific;
};
with deviceSpecific; {
  users.groups.smbgrp.gid = 2001;
  # TODO: add nologin shell to this user
  users.users.smbuser =
  lib.mkIf isHost {
    isNormalUser = false;
    extraGroups = [
      "smbgrp"
    ];
    description = "User for samba sharing";
  };
  services.samba =
  lib.mkIf isHost {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    invalidUsers = [ "root" ];
    nsswins = false;
    securityType = "user";
    syncPasswordsByPam = false;
    configText = ''
      [global]
      server string = samba home server
      server role = standalone server
      disable netbios = yes
      smb ports = 445

      [data]
      path = /media/data
      browsable = yes
      read only = no
      force create mode = 0660
      force directory mode = 2770
      valid users = @smbgrp

      [files]
      path = /media/files
      browsable = yes
      read only = no
      force create mode = 0660
      force directory mode = 2770
      valid users = @smbgrp
    '';
  };
  environment.systemPackages = [
    pkgs.cifs-utils
  ] ++ lib.optionals isHost [
    config.services.samba.package
  ];
}