{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
  renderGid = toString config.users.groups.render.gid;
  videoGid = toString config.users.groups.video.gid;
  inputGid = toString config.users.groups.input.gid;
  intro-skipper-fix = pkgs.writeText "intro-skipper-fix" ''
    #!/bin/bash
    chown abc /usr/share/jellyfin/web/index.html
  '';
in
{
  options.ataraxia.containers.media-stack = {
    jellyfin = mkEnableOption "Enable jellyfin container";
  };

  config = mkIf cfg.jellyfin {
    virtualisation.quadlet.containers.jellyfin = {
      autoStart = true;
      containerConfig = {
        # Tags: 10.11.6, version-10.11.6ubu2404, 10.11.6ubu2404-ls19
        image = "docker.io/linuxserver/jellyfin@sha256:7b29a93a6020f8d5f6c60df381a5ab7d57aa83cda4beb3631bd2bfbbcb1497af";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
          http_proxy = "http://10.10.10.6:8888";
          https_proxy = "http://10.10.10.6:8888";
        };
        addGroups = [
          renderGid
          videoGid
          inputGid
        ];
        devices = [ "/dev/dri/renderD128" ];
        # podmanArgs = [ "--privileged" ];
        volumes = [
          "${nas-path}/configs/jellyfin:/config"
          "${nas-path}/media:/data/media"
          "${intro-skipper-fix}:/custom-cont-init.d/intro-skipper-fix:ro"
        ];
      };
    };
  };
}
