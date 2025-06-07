{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkOption
    ;
  inherit (lib.types) listOf package;
  cfg = config.ataraxia.networkmanager;
in
{
  options.ataraxia.networkmanager = {
    enable = mkEnableOption "Enable NetworkManager";
    plugins = mkOption {
      type = listOf package;
      default = [ ];
      description = ''
        List of NetworkManager plug-ins to enable.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager.enable = mkForce true;
    networking.networkmanager.plugins = mkForce cfg.plugins;

    persist.state.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
