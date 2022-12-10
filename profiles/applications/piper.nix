{ config, pkgs, lib, ... }: {
  config = lib.mkIf (config.device == "AMD-Workstation") {
    services.ratbagd.enable = true;
    home-manager.users.${config.mainuser}.home.packages = [ pkgs.piper ];
  };
}