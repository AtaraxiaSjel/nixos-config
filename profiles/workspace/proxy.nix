{ config, pkgs, lib, ... }: {
  secrets.xray-config = {};

  services.xray = {
    enable = true;
    configFile = config.secrets.xray-config.decrypted;
  };

}