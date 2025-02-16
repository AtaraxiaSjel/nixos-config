{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.kavita = {
    autoStart = true;
    # Tags: 0.8.4, version-v0.8.4.2, v0.8.4.2-ls63
    image = "docker.io/linuxserver/kavita@sha256:03b68c3137f986dc8a9b126c9e0fd7f356e0e9c9e83ffa8fa6356cd028288c8a";
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Moscow";
      DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "true";
    };
    extraOptions = [ "--pod=media-stack" ];
    volumes = [
      "${nas-path}/configs/kavita:/config"
      "${nas-path}/media/books:/data/books"
      "${nas-path}/media/comics:/data/comics"
      "${nas-path}/media/fanfics:/data/fanfics"
      "${nas-path}/media/manga:/data/manga"
      "${nas-path}/media/novels:/data/novels"
    ];
  };
}