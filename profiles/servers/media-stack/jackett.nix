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
    # Tags: 0.22.1730, version-v0.22.1730, v0.22.1730-ls727
    image = "docker.io/linuxserver/jackett@sha256:e05f37aca02259c8d558fc60510347bfec6f345dbb96032587c545ca90a71836";
    volumes = [
      "${nas-path}/configs/jackett:/config"
    ];
  };
}