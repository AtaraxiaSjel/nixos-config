{ pkgs, lib, config, ... }:
{
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
    usePredictableInterfaceNames = true;
    hostName = config.device;
  };

  persist.state.directories = lib.mkIf config.networking.networkmanager.enable [
    "/etc/NetworkManager/system-connections"
  ];
}
