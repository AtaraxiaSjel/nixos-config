{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.lidarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "docker.io/linuxserver/lidarr:version-2.7.1.4417";
    volumes = [
      "${nas-path}/configs/lidarr/config:/config"
      "${nas-path}/configs/lidarr/custom-services.d:/custom-services.d"
      "${nas-path}/configs/lidarr/custom-cont-init.d:/custom-cont-init.d"
      "${nas-path}:/data"
    ];
  };
}
