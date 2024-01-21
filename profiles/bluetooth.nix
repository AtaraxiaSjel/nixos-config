{ config, pkgs, lib, ... }: {
  config = lib.mkIf (!config.deviceSpecific.isServer) {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = { Experimental = true; };
      };
    };

    persist.state.directories = [ "/var/lib/bluetooth" ];

    home-manager.users.${config.mainuser}.programs.zsh.shellAliases = let
      headphones = "D8:37:3B:60:5D:55";
    in {
      "hpc" = "bluetoothctl connect ${headphones}";
      "hpd" = "bluetoothctl disconnect ${headphones}";
    };
  };
}
