{ config, pkgs, ... }:
let
  nas-path = "/media/nas/media-stack";
  renderGid = toString config.users.groups.render.gid;
  videoGid = toString config.users.groups.video.gid;
  inputGid = toString config.users.groups.input.gid;
  intro-skipper-fix = pkgs.writeText "intro-skipper-fix" ''
    #!/bin/bash
    chown abc /usr/share/jellyfin/web/index.html
  '';
in {
  virtualisation.oci-containers.containers.jellyfin = {
    autoStart = true;
    # Tags: 10.10.5, version-10.10.5ubu2404, 10.10.5ubu2404-ls52
    image = "docker.io/linuxserver/jellyfin@sha256:7cdcd4b6b60765290af7a2740960ce30c1f5548313ae60f7e23f6995ed4d147e";
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
}
