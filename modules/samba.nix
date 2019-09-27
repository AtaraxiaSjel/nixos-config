{ config, lib, pkgs, ... }:
with rec {
  inherit (config) deviceSpecific;
};
with deviceSpecific; {
  users.groups.smbgrp.gid = 2001;
  # TODO: add nologin shell to this user
  users.users.smbuser =
  lib.mkIf (isHost || config.device == "NixOS-VM") {
    isNormalUser = false;
    extraGroups = [
      "smbgrp"
    ];
    description = "User for samba sharing";
  };
  services.samba =
  lib.mkIf (isHost || config.device == "NixOS-VM") {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    invalidUsers = [ "root" ];
    nsswins = false;
    securityType = "user";
    syncPasswordsByPam = false;
    # shares = {
    # };
    # extraConfig = ''
    configText = ''
      [global]
      server string = samba home server
      server role = standalone server
      disable netbios = yes
      smb ports = 445

      [data]
      path = /shared/data
      browsable = yes
      read only = yes
      force create mode = 0660
      force directory mode = 2770
      valid users = @smbgrp

      [files]
      path = /shared/files
      browsable = yes
      read only = no
      # guest only = yes
      force create mode = 0660
      force directory mode = 2770
      # force user = smbuser
      valid users = @smbgrp
    '';
  };
  environment.systemPackages =
  if (isHost || config.device == "NixOS-VM") then
    [ config.services.samba.package ]
  else
    [ ];
}