{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.jellyfin = {
    autoStart = true;
    image = "cr.hotio.dev/hotio/jellyfin:release-10.8.9-1";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" "--device=/dev/dri:/dev/dri" ];
    # ports = [ "127.0.0.1:8096:8096/tcp" ];
    volumes = [
      "${nas-path}/configs/jellyfin:/config"
      "${nas-path}/media:/data/media"
    ];
  };
}