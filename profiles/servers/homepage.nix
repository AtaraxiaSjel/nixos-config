{ config, lib, pkgs, ... }:
let
  nas-path = "/media/nas/containers";
in {
  virtualisation.oci-containers.containers.homepage = {
    autoStart = true;
    image = "ghcr.io/benphelps/homepage:v0.6.29";
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    ports = [ "127.0.0.1:3000:3000/tcp" ];
    volumes = [
      "${nas-path}/homepage/config:/app/config"
      "${nas-path}/homepage/icons:/app/public/icons"
      "/var/run/docker.sock:/var/run/docker.sock"
    ];
  };
}