{ config, pkgs, lib, ... }:
let
  waydroidGbinderConf = pkgs.writeText "waydroid.conf" ''
    [General]
    ApiLevel = 30
  '';
in {
  config = {
    environment.etc."gbinder.d/waydroid.conf".source = lib.mkForce waydroidGbinderConf;
    virtualisation.waydroid.enable = true;
    home-manager.users.${config.mainuser}.home.packages = [ pkgs.waydroid-script ];

    persist.state.directories = [ "/var/lib/waydroid" ];
    persist.state.homeDirectories = [ ".local/share/waydroid" ];
  };
}
