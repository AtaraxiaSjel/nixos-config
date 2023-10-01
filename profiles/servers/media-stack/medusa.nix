{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.medusa = {
    autoStart = true;
    image = "docker.io/linuxserver/medusa:v1.0.17-ls155";
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Moscow";
      # HTTP_PROXY = "http://192.168.0.6:8888";
      # HTTPS_PROXY = "http://192.168.0.6:8888";
    };
    extraOptions = [ "--pod=media-stack" ];
    volumes = [
      "${nas-path}/configs/medusa:/config"
      "${nas-path}:/data"
    ];
  };
}