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
    # Tags: 0.22.1433, version-v0.22.1433, v0.22.1433-ls679
    image = "docker.io/linuxserver/jackett@sha256:26ac30423b9808e0716dcde7791841296beacd95e820cfbfc4d50666ea0d1fb8";
    volumes = [
      "${nas-path}/configs/jackett:/config"
    ];
  };
}