{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.jackett = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "cr.hotio.dev/hotio/jackett:release-0.20.3546";
    volumes = [
      "${nas-path}/configs/jackett:/config"
    ];
  };
}