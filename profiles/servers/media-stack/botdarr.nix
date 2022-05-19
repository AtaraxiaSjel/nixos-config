{ config, lib, pkgs, ... }:
with config.virtualisation.oci-containers; {
  secrets.botdarr-telegram = {
    services = [ "${backend}-botdarr-telegram.service" ];
  };
  secrets.botdarr-matrix = {
    services = [ "${backend}-botdarr-matrix.service" ];
  };

  virtualisation.oci-containers.containers.botdarr-telegram = {
    autoStart = true;
    extraOptions = [
      "--network=media"
    ];
    image = "shayaantx/botdarr:5.3.4";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/botdarr-telegram/logs:/home/botdarr/logs"
      "/media/configs/botdarr-telegram/database:/home/botdarr/database"
      "${config.secrets.botdarr-telegram.decrypted}:/home/botdarr/config/properties:ro"
    ];
  };

  virtualisation.oci-containers.containers.botdarr-matrix = {
    autoStart = true;
    extraOptions = [
      "--network=media"
    ];
    image = "shayaantx/botdarr:5.3.4";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/botdarr-matrix/logs:/home/botdarr/logs"
      "/media/configs/botdarr-matrix/database:/home/botdarr/database"
      "${config.secrets.botdarr-matrix.decrypted}:/home/botdarr/config/properties:ro"
    ];
  };
}