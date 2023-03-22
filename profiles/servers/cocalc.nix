{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/containers";
in {
  virtualisation.oci-containers.containers.cocalc = {
    autoStart = true;
    image = "docker.io/ataraxiadev/cocalc-latex:1b335d368d26";
    ports = [ "127.0.0.1:9099:443/tcp" ];
    volumes = [
      "${nas-path}/cocalc:/projects"
      "${nas-path}/databases/cocalc:/projects/postgres"
    ];
  };
}