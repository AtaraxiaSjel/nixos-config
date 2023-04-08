{ config, lib, pkgs, ... }:
let
  nas-path = "/media/nas/containers";
in {
  virtualisation.oci-containers.containers.homepage = {
    autoStart = true;
    image = "ghcr.io/benphelps/homepage:latest";
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    extraOptions = [ "--pull=newer" ];
    ports = [ "127.0.0.1:3000:3000/tcp" ];
    volumes = [
      "${nas-path}/homepage:/app/config"
    ];
  };
}