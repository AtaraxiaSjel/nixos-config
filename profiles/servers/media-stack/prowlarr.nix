{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.prowlarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "cr.hotio.dev/hotio/prowlarr:release-1.2.2.2699";
    volumes = [
      "${nas-path}/configs/prowlarr:/config"
      "${nas-path}/torrents:/data"
    ];
  };
}