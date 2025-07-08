{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;

  backend = "podman";
  nas-path = "/media/nas/media-stack";
  volume = "local-nfs";
  nfs-share = "10.10.10.11:/";
in
{
  options.ataraxia.containers.media-stack = {
    qbittorrent = mkEnableOption "Enable qbittorrent container";
  };

  config = mkIf cfg.qbittorrent {
    virtualisation.oci-containers.containers.qbittorrent = {
      autoStart = true;
      # Tags: 5.1.2, version-5.1.2-r0, 5.1.2-r0-ls402
      image = "docker.io/linuxserver/qbittorrent@sha256:94c8c82291c4fcf86084a6efb9f806786296fad48739e4723dc9a5393073a2ae";
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        TZ = "Europe/Moscow";
        TORRENTING_PORT = "7000";
        DOCKER_MODS = "ghcr.io/gabe565/linuxserver-mod-vuetorrent";
      };
      extraOptions = [ "--pod=media-stack" ];
      volumes = [
        "${nas-path}/configs/qbittorrent:/config"
        "${nas-path}:/data"
        "${volume}:/nfs"
      ];
    };

    systemd.services."podman-create-volume-${volume}" =
      let
        start = pkgs.writeShellScript "create-volume-${volume}" ''
          podman volume exists ${volume} || podman volume create --opt type=nfs4 --opt o=rw --opt device=${nfs-share} ${volume}
        '';
      in
      rec {
        path = [ config.virtualisation.podman.package ];
        before = [ "${backend}-qbittorrent.service" ];
        requiredBy = before;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = start;
        };
      };
  };
}
