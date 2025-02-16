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
    # Tags: 5.18.4, version-5.18.4.9674, 5.18.4.9674-ls259
    image = "docker.io/linuxserver/radarr@sha256:f4c9c64c42e84a3c03590afd9da2e420c69b5e936b4549778c5d4c00d907ba33";
    volumes = [
      "${nas-path}/configs/radarr:/config"
      "${nas-path}:/data"
    ];
  };
}