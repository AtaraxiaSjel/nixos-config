{ config, pkgs, ... }:
let
  backend = "podman";
  nas-path = "/media/nas/media-stack";
  volume = "local-nfs";
  nfs-share = "10.10.10.11:/";
in {
  virtualisation.oci-containers.containers.qbittorrent = {
    autoStart = true;
    image = "docker.io/linuxserver/qbittorrent:5.0.1-r0-ls363";
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

  systemd.services."podman-create-volume-${volume}" = let
    start = pkgs.writeShellScript "create-volume-${volume}" ''
      podman volume exists ${volume} || podman volume create --opt type=nfs4 --opt o=rw --opt device=${nfs-share} ${volume}
    '';
  in rec {
    path = [ config.virtualisation.podman.package ];
    before = [ "${backend}-qbittorrent.service" ];
    requiredBy = before;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = start;
    };
  };
}