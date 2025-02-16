{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.openbooks = {
    autoStart = true;
    # Tags: 4.5.0
    image = "ghcr.io/evan-buss/openbooks@sha256:5a1640d297d5bdcb6ebbb7e164141a8f25f0264c1ab0fc2a3115e834a94a35e0";
    cmd = [
      "--name" "AtaraxiaDev" "--persist" "--searchbot" "searchook" "--tls"
    ];
    ports = [ "127.0.0.1:8097:80/tcp" ];
    volumes = [
      "${nas-path}/media/books/openbooks:/books"
    ];
  };
}