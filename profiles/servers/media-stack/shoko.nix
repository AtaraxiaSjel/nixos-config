{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.shokoserver = {
    autoStart = true;
    environment = {
      PUID = "1019";
      PGID = "1005";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "shokoanime/server:v4.1.1";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/shokoserver/config:/home/shoko/.shoko"
      "/media/data:/data"
    ];
  };
}