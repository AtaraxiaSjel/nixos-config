{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.sonarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    # Tags: 4.0.13, version-4.0.13.2932, 4.0.13.2932-ls271
    image = "docker.io/linuxserver/sonarr@sha256:28d9dcbc846aed74bd47dc90305e016183443ddc3dfa3e8bcac268fc653a6e5e";
    volumes = [
      "${nas-path}/configs/sonarr:/config"
      "${nas-path}:/data"
    ];
  };
}