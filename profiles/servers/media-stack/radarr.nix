{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.radarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
      HTTP_PROXY = "http://192.168.0.6:8888";
      HTTPS_PROXY = "http://192.168.0.6:8888";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "cr.hotio.dev/hotio/radarr:release-4.7.5.7809";
    volumes = [
      "${nas-path}/configs/radarr:/config"
      "${nas-path}:/data"
    ];
  };
}