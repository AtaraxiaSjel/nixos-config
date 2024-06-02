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
    image = "docker.io/linuxserver/sonarr:version-4.0.4.1491";
    volumes = [
      "${nas-path}/configs/sonarr:/config"
      "${nas-path}:/data"
    ];
  };
}