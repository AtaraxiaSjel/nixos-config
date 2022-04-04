{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.prowlarr = {
    autoStart = true;
    environment = {
      PUID = "1016";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/prowlarr:testing-0.2.0.1448";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/prowlarr/config:/config"
      "/media/data/torrents:/data/torrents"
    ];
  };
}