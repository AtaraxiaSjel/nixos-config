{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.radarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "docker.io/linuxserver/radarr:5.2.6";
    volumes = [
      "${nas-path}/configs/radarr:/config"
      "${nas-path}:/data"
    ];
  };
}