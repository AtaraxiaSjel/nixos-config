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
        # Tags: 5.1.2, version-5.1.2-r2, 5.1.2-r2-ls415
        image = "docker.io/linuxserver/qbittorrent@sha256:ffa4e82aa55e3bd3d2d99151f235fcd41b976303c4d4029940363452a59a3833";
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
