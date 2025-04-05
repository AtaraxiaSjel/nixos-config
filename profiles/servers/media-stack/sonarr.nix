{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.sonarr = {
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    # Tags: 4.0.14, version-4.0.14.2939, 4.0.14.2939-ls277
    image = "docker.io/linuxserver/sonarr@sha256:7342ef32dd9cd6d13638765cfb8034edd4c80b0584f427159fd7f5ddeef5399d";
    volumes = [
      "${nas-path}/configs/sonarr:/config"
      "${nas-path}:/data"
    ];
  };
}