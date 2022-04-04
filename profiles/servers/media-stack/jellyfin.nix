{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.jellyfin = {
    autoStart = true;
    environment = {
      PUID = "1010";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/jellyfin:release-10.7.7-1";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/jellyfin/config:/config"
      "/media/data/media:/data/media"
    ];
  };
}