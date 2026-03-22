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
        memory = "6g";
        # Tags: 5.1.4, version-5.1.4-r2, 5.1.4-r2-ls446
        image = "docker.io/linuxserver/qbittorrent@sha256:570aeb63bdedcb5f9dd2500bd8f0a75581ba07c518c05cabbef0cfeb15451b3f";
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
