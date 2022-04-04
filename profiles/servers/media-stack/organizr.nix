{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.organizr = {
    autoStart = true;
    environment = {
      PUID = "1017";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "organizr/organizr";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/organizr/config:/config"
    ];
  };
}