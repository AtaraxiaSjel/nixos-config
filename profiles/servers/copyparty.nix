{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas";
in {
  virtualisation.oci-containers.containers.copyparty = {
    autoStart = true;
    image = "docker.io/copyparty/min";
    cmd = [
      "--xdev" "--xvol"
      # "-e2dsa" "-e2ts"
      # "--re-maxage 600"
      # "--hist /cache/copyparty"
      # "--no-robots"
      "-q" "--http-only" "--no-dav"
      "-s" "--no-logues" "--no-readme"
      # "-i localhost"
    ];
    ports = [ "127.0.0.1:3923:3923/tcp" ];
    user = "1000:100";
    volumes = [
      "${nas-path}:/w"
    ];
  };
}