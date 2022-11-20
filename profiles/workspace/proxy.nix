{ config, pkgs, lib, ... }: {
  disabledModules = [ "services/networking/xray.nix" ];

  secrets.xray-config = {};

  services.xray-custom = {
    enable = true;
    settingsFile = config.secrets.xray-config.decrypted;
  };

}