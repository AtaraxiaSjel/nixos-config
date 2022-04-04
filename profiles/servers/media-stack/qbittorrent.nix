{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.qbittorrent = {
    autoStart = true;
    environment = {
      PUID = "1018";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/qbittorrent:release-4.4.1";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/qbittorrent/config:/config"
      "/media/data/torrents:/data/torrents"
    ];
  };
}