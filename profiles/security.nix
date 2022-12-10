{ config, pkgs, lib, ... }:
with config.deviceSpecific; {
  security.apparmor.enable = !isContainer;
  programs.firejail.enable = true;
  users.mutableUsers = false;
  users.users.${config.mainuser} = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "audio"
      "cdrom"
      "corectrl"
      "dialout"
      "disk"
      "docker"
      "input"
      "kvm"
      "libvirtd"
      "lp"
      "lxd"
      "networkmanager"
      "podman"
      "qemu-libvirtd"
      "scanner"
      "smbuser"
      "video"
      # "wheel" # remove?
    ];
    description = "AtaraxiaDev";
    uid = 1000;
    hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
    shell = pkgs.zsh;
  };
  # Safe, because we using doas
  users.allowNoPasswordLogin = true;
  # FIXME
  security.sudo = {
    enable = true;
    extraRules = [{
      users = [ config.mainuser ];
      commands = [{
        command = "/run/current-system/sw/bin/nixos-rebuild";
        options = [ "SETENV" "NOPASSWD" ];
      } {
        command = "/run/current-system/sw/bin/nix";
        options = [ "SETENV" "NOPASSWD" ];
      } {
        command = "/run/current-system/sw/bin/nix-shell";
        options = [ "SETENV" "NOPASSWD" ];
      }];
    }];
    # extraConfig = lib.concatStrings [''
    #   ${config.mainuser} ALL = (root) NOPASSWD: /run/current-system/sw/bin/btrfs fi usage /
    # ''
    # (if (isLaptop) then ''
    #   ${config.mainuser} ALL = (root) NOPASSWD: /run/current-system/sw/bin/tlp-stat
    #   ${config.mainuser} ALL = (root) NOPASSWD: /run/current-system/sw/bin/tlp ac
    #   ${config.mainuser} ALL = (root) NOPASSWD: /run/current-system/sw/bin/tlp bat
    # '' else "")
    # ];
  };
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ config.mainuser ];
      keepEnv = true;
      persist = true;
    } {
      users = [ config.mainuser ];
      noPass = true;
      keepEnv = true;
      cmd = "/run/current-system/sw/bin/btrfs";
      args = [ "fi" "usage" "/" ];
    }] ++ lib.optionals isLaptop [{
      users = [ config.mainuser ];
      noPass = true;
      keepEnv = true;
      cmd = "/run/current-system/sw/bin/tlp";
    } {
      users = [ config.mainuser ];
      noPass = true;
      keepEnv = true;
      cmd = "/run/current-system/sw/bin/tlp-stat";
    }];
  };
  systemd.services."user@" = { serviceConfig = { Restart = "always"; }; };
  services.getty.autologinUser = config.mainuser;
}
