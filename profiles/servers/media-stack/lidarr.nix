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
    # Tags: 2.10.3, version-2.10.3.4602, 2.10.3.4602-ls36
    image = "docker.io/linuxserver/lidarr@sha256:4c3d6942aa0ae3a7da5a4d6a59ee96e43777d834b4234f539bbb5d10a2db2900";
    volumes = [
      "${nas-path}/configs/lidarr/config:/config"
      "${nas-path}/configs/lidarr/custom-services.d:/custom-services.d"
      "${nas-path}/configs/lidarr/custom-cont-init.d:/custom-cont-init.d"
      "${nas-path}:/data"
    ];
  };
}
