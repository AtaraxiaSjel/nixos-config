{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.medusa = {
    autoStart = true;
    # Tags: 1.0.22, version-v1.0.22, v1.0.22-ls216
    image = "docker.io/linuxserver/medusa@sha256:78fa244f473e5e791d1c01db61300e33dd5ebc9ab9def206b53bc2621d212f71";
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