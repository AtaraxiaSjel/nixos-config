{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  pod-name = "media-stack";
  open-ports = [
    # caddy
    "127.0.0.1:8180:8180"
    "0.0.0.0:7000:7000"
    "0.0.0.0:7000:7000/udp"
  ];
  pod-dns = "10.10.10.1";
in {
  imports = [
    ./caddy.nix
    ./jackett.nix
    ./jellyfin.nix
    ./kavita.nix
    ./lidarr.nix
    ./medusa.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./recyclarr.nix
    ./sonarr.nix
  ];

  systemd.services."podman-create-${pod-name}" = let
    portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
    start = pkgs.writeShellScript "create-pod-${pod-name}" ''
      podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping} --dns ${pod-dns}
    '';
    stop = "podman pod rm -i -f ${pod-name}";
  in rec {
    path = [ pkgs.coreutils config.virtualisation.podman.package ];
    before = [
      "${backend}-media-caddy.service"
      "${backend}-jackett.service"
      "${backend}-jellyfin.service"
      "${backend}-kavita.service"
      "${backend}-lidarr.service"
      "${backend}-medusa.service"
      "${backend}-qbittorrent.service"
      "${backend}-radarr.service"
      "${backend}-recyclarr.service"
      "${backend}-sonarr.service"
    ];
    requiredBy = before;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = start;
      ExecStop = stop;
    };
  };
}