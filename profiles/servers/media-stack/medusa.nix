{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.medusa = {
    autoStart = true;
    image = "docker.io/pymedusa/medusa";
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Moscow";
      # HTTP_PROXY = "http://192.168.0.6:8888";
      # HTTPS_PROXY = "http://192.168.0.6:8888";
    };
    extraOptions = [ "--pod=media-stack" ];
    # ports = [ "127.0.0.1:8081:8081/tcp" ];
    volumes = [
      "${nas-path}/configs/medusa:/config"
      "${nas-path}:/data"
      # "${nas-path}/torrents:/downloads"
      # "${nas-path}/media/anime:/tv"
    ];
  };
}