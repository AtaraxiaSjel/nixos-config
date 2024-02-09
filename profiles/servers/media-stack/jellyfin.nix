{ config, ... }:
let
  nas-path = "/media/nas/media-stack";
  renderGid = toString config.users.groups.render.gid;
  videoGid = toString config.users.groups.video.gid;
  inputGid = toString config.users.groups.input.gid;
in {
  virtualisation.oci-containers.containers.jellyfin = {
    autoStart = true;
    image = "docker.io/linuxserver/jellyfin:10.8.13";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
      DOCKER_MODS = "linuxserver/mods:universal-package-install";
      INSTALL_PACKAGES = "yt-dlp";
    };
    extraOptions = [
      "--pod=media-stack"
      "--device=/dev/dri/renderD128:/dev/dri/renderD128"
      "--group-add=${renderGid},${videoGid},${inputGid}"
      # "--privileged"
    ];
    volumes = [
      "${nas-path}/configs/jellyfin:/config"
      "${nas-path}/media:/data/media"
    ];
  };
}