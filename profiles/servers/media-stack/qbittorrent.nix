{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.qbittorrent = {
    autoStart = true;
    image = "docker.io/linuxserver/qbittorrent:5.0.1-r0-ls363";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
      TORRENTING_PORT = "7000";
    };
    extraOptions = [ "--pod=media-stack" ];
    volumes = [
      "${nas-path}/configs/qbittorrent:/config"
      "${nas-path}:/data"
    ];
  };
}