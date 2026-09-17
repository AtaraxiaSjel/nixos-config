{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ataraxia.lists) ports;

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
        # updater: strategy=semver-best, semver=>=5.0,<6.0
        # Tags: 5.2.3_v2.0.14-ls476, latest, 5.2.3
        image = "docker.io/linuxserver/qbittorrent@sha256:2be038f3421f60f62e8e4bf201f66f385b68e4fbc9ed3ab79051069ea22e2650";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
          TORRENTING_PORT = "7000";
          WEBUI_PORT = ports.qbittorrent.str;
          DOCKER_MODS = "ghcr.io/vuetorrent/vuetorrent-lsio-mod";
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
