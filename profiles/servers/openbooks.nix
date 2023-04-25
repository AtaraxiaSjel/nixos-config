{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.openbooks = {
    autoStart = true;
    image = "docker.io/evanbuss/openbooks:4.5.0";
    cmd = [ "--name" "AtaraxiaDev" "--persist" "--searchbot" "searchook" ];
    ports = [ "127.0.0.1:8097:80/tcp" ];
    volumes = [
      "${nas-path}/media/books/openbooks:/books"
    ];
  };
}