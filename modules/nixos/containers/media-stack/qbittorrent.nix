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
        # Tags: 5.2.2, version-5.2.2_v2.0.13, 5.2.2_v2.0.13-ls465
        image = "docker.io/linuxserver/qbittorrent@sha256:dd24a5f3db32bc1425d3f8dc95e8aca8ac5a35905d798171230edf33f516d9a4";
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
