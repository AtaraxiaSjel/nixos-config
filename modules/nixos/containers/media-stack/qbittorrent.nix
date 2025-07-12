{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  volumes = config.virtualisation.quadlet.volumes;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
  nfs-share = "10.10.10.11:/";
in
{
  options.ataraxia.containers.media-stack = {
    qbittorrent = mkEnableOption "Enable qbittorrent container";
  };

  config = mkIf cfg.qbittorrent {
    virtualisation.quadlet.containers.qbittorrent = {
      autoStart = true;
      containerConfig = {
        # Tags: 5.1.2, version-5.1.2-r1, 5.1.2-r1-ls404
        image = "docker.io/linuxserver/qbittorrent@sha256:a53a9f228ab3cdddd594d44138fbbf579fb40c88502bf491d725b0b8e83ab253";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
          TORRENTING_PORT = "7000";
          DOCKER_MODS = "ghcr.io/gabe565/linuxserver-mod-vuetorrent";
        };

        volumes = [
          "${nas-path}/configs/qbittorrent:/config"
          "${nas-path}:/data"
          "${volumes.nfs-share.ref}:/nfs"
        ];
      };
    };

    virtualisation.quadlet.volumes.nfs-share = {
      volumeConfig = {
        device = nfs-share;
        type = "nfs4";
        options = "rw";
      };
    };
  };
}
