{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.recyclarr = {
    autoStart = true;
    environment = {
      CRON_SCHEDULE = "@daily";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "ghcr.io/recyclarr/recyclarr:5.1.1";
    volumes = [
      "${nas-path}/configs/recyclarr:/config"
    ];
    user = "1000:100";
  };
}