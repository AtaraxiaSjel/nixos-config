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
  install-deno = pkgs.writeScript "install-deno" ''
    #!/bin/bash
    echo "Installing Deno..."
    curl -fsSL https://deno.land/install.sh | sh
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
        # updater: strategy=semver-best, allow=12*
        # Tags: 12.1ubu2604-ls50, latest, version-12.1ubu2604
        image = "docker.io/linuxserver/jellyfin@sha256:51252e7a416e703cdc3cd91e8a54673a2430cc80409be8a38abe511411577b95";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
          # DOCKER_MODS = "linuxserver/mods:universal-package-install|linuxserver/mods:jellyfin-opencl-intel";
          DOCKER_MODS = "linuxserver/mods:universal-package-install";
          INSTALL_PACKAGES = "yt-dlp|unzip";
          DENO_INSTALL = "/usr";
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
          "${nas-path}/media/youtube:/data/media/youtube:ro"
          "${install-deno}:/custom-cont-init.d/install-deno:ro"
        ];
      };
    };
  };
}
