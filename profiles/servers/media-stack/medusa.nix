{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.medusa = {
    autoStart = true;
    image = "docker.io/linuxserver/medusa:v1.0.21-ls202";
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    volumes = [
      "${nas-path}/configs/medusa:/config"
      "${nas-path}:/data"
    ];
  };
}