{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
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
    virtualisation.oci-containers.containers.jellyfin = {
      autoStart = true;
      # Tags: 10.10.7, version-10.10.7ubu2404, 10.10.7ubu2404-ls68
      image = "docker.io/linuxserver/jellyfin@sha256:d325675bce77eda246f13d0aa2bf94002d4e426e6e1783594cf9b6df164fcb23";
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        TZ = "Europe/Moscow";
        http_proxy = "http://10.10.10.6:8888";
        https_proxy = "http://10.10.10.6:8888";
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
        "${intro-skipper-fix}:/custom-cont-init.d/intro-skipper-fix:ro"
      ];
    };
  };
}
