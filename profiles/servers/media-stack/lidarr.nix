{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.lidarr = {
    autoStart = true;
    environment = {
      PUID = "1014";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/lidarr:release-0.8.1.2135";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/lidarr/config:/config"
      "/media/data:/data"
    ];
  };
}
