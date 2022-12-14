{ config, pkgs, lib, ... }:
let
  waydroidGbinderConf = pkgs.writeText "waydroid.conf" ''
    [General]
    ApiLevel = 30
  '';
  # anboxGbinderConf = pkgs.writeText "anbox.conf" ''
  #   [Protocol]
  #   /dev/anbox-binder = aidl2
  #   /dev/anbox-vndbinder = aidl2
  #   /dev/anbox-hwbinder = hidl
  #   [ServiceManager]
  #   /dev/anbox-binder = aidl2
  #   /dev/anbox-vndbinder = aidl2
  #   /dev/anbox-hwbinder = hidl
  # '';
in {
  config = lib.mkIf config.deviceSpecific.isGaming {
    environment.etc."gbinder.d/waydroid.conf".source = lib.mkForce waydroidGbinderConf;
    # environment.etc."gbinder.d/anbox.conf".source = lib.mkForce anboxGbinderConf;
    virtualisation.waydroid.enable = true;
    # virtualisation.lxd.enable = true;
    home-manager.users.${config.mainuser}.home.packages = [ pkgs.waydroid-script ];

    persist.state.directories = [ "/var/lib/waydroid" ];
    persist.state.homeDirectories = [ ".local/share/waydroid" ];
  };
}
