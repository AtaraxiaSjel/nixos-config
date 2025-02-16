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
    # Tags: 2.9.6, version-2.9.6.4552, 2.9.6.4552-ls30
    image = "docker.io/linuxserver/lidarr@sha256:c3aae1e32f7e2b76c6aa0e546a16f3feb570455882a5c9d51c8aec9e53328d66";
    volumes = [
      "${nas-path}/configs/lidarr/config:/config"
      "${nas-path}/configs/lidarr/custom-services.d:/custom-services.d"
      "${nas-path}/configs/lidarr/custom-cont-init.d:/custom-cont-init.d"
      "${nas-path}:/data"
    ];
  };
}
