{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.jackett = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "docker.io/linuxserver/jackett:0.21.1712";
    volumes = [
      "${nas-path}/configs/jackett:/config"
    ];
  };
}