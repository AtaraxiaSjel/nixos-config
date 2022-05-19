{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.sonarr-anime = {
    autoStart = true;
    environment = {
      PUID = "1012";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/sonarr:release-3.0.8.1507";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/sonarr-anime/config:/config"
      "/media/data:/data"
    ];
  };

  virtualisation.oci-containers.containers.sonarr-tv = {
    autoStart = true;
    environment = {
      PUID = "1013";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/sonarr:release-3.0.8.1507";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/sonarr-tv/config:/config"
      "/media/data:/data"
    ];
  };
}