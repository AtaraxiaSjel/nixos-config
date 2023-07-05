{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
  renderGid = toString config.users.groups.render.gid;
  videoGid = toString config.users.groups.video.gid;
  inputGid = toString config.users.groups.input.gid;
in {
  virtualisation.oci-containers.containers.jellyfin = {
    autoStart = true;
    image = "lscr.io/linuxserver/jellyfin:10.8.10";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
      DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
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