{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.radarr = {
    autoStart = true;
    environment = {
      PUID = "1011";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/radarr:release-4.1.0.6175";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/radarr/config:/config"
      "/media/data:/data"
    ];
  };
}