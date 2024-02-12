{ config, lib, ... }: {
  # FIXME: completely remove sudo
  security.sudo = {
    enable = true;
    extraRules = [{
      users = [ "deploy" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
  };
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ config.mainuser ];
      keepEnv = true;
      persist = true;
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
    } {
      users = [ config.mainuser ];
      noPass = true;
      keepEnv = true;
      cmd = "/run/current-system/sw/bin/nixos-rebuild";
    }];
  };
}