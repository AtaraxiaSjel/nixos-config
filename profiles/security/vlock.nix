{ config, lib, ... }: {
  security.sudo.enable = lib.mkForce false;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ config.mainuser ];
      keepEnv = true;
      persist = true;
    } {
      users = [ "deploy" ];
      noPass = true;
      keepEnv = true;
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