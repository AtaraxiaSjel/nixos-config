{ config, pkgs, lib, ... }: {
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
    }] ++ lib.optionals config.deviceSpecific.isLaptop [{
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
}