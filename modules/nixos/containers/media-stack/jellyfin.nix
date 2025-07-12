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
        # Tags: 10.10.7, version-10.10.7ubu2404, 10.10.7ubu2404-ls69
        image = "docker.io/linuxserver/jellyfin@sha256:8275e69a75a07ba69e76590472a1e0c5bdf5ec2df6ce03eee6d961e8cff0680c";
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
