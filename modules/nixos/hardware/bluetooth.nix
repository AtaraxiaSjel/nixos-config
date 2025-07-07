{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.defaults.bluetooth;
in
{
  options.ataraxia.defaults.bluetooth = {
    enable = mkEnableOption "Default bluetooth settings";
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    persist.state.directories = [ "/var/lib/bluetooth" ];
  };
}
