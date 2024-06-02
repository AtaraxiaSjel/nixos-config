{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.qbittorrent = {
    autoStart = true;
    image = "docker.io/linuxserver/qbittorrent:4.6.4";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    # ports = [ "127.0.0.1:8082:8080/tcp" ];
    volumes = [
      "${nas-path}/configs/qbittorrent:/config"
      "${nas-path}:/data"
    ];
  };
}