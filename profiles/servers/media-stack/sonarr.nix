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
    image = "ghcr.io/hotio/sonarr:nightly-4.0.0.688";
    volumes = [
      "${nas-path}/configs/sonarr:/config"
      "${nas-path}:/data"
    ];
  };
}