{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.medusa = {
    autoStart = true;
    # Tags: 1.0.22, version-v1.0.22, v1.0.22-ls211
    image = "docker.io/linuxserver/medusa@sha256:397636cc7e421ee284d4fb8d9b07874ce41155b419b3e8419dce389fcdb465a7";
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