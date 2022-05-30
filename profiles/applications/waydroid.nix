{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.deviceSpecific.isGaming {
    virtualisation.waydroid.enable = true;
    virtualisation.lxd.enable = true;
  };
}