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
      "render"
      "scanner"
      "systemd-journal"
      "smbuser"
      "video"
      # "wheel" # remove?
    ];
    description = "AtaraxiaDev";
    uid = 1000;
    hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";

    shell = pkgs.zsh;
  };
  # Safe, because we using doas
  users.allowNoPasswordLogin = true;
  # FIXME: completely remove sudo
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
      } {
        command = "/run/current-system/sw/bin/extra-container";
        options = [ "SETENV" "NOPASSWD" ];
      } {
        command = "/run/current-system/sw/bin/chown ${config.mainuser} /tmp/.X11-unix";
        options = [ "SETENV" "NOPASSWD" ];
      }
      # {
      #   command = "/run/current-system/sw/bin/deploy";
      #   options = [ "SETENV" "NOPASSWD" ];
      # }
      ];
    }];
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
    } {
      users = [ config.mainuser ];
      keepEnv = false;
      cmd = "/run/current-system/sw/bin/podman";
      args = [ "build" ];
    }];
  };
  systemd.services."user@" = { serviceConfig = { Restart = "always"; }; };
  services.getty.autologinUser = config.mainuser;
}
