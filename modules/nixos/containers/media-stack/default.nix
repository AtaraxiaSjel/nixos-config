{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.ataraxia.containers.media-stack;

  backend = config.virtualisation.oci-containers.backend;
  pod-name = "media-stack";
  open-ports = [
    # caddy
    "127.0.0.1:8180:8180"
    # qbittorrent
    "0.0.0.0:7000:7000"
    "0.0.0.0:7000:7000/udp"
  ];
  pod-dns = "10.10.10.1";
in
{
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

  options.ataraxia.containers.media-stack = {
    enable = mkEnableOption "Enable media-stack containers";
  };

  config = mkIf cfg.enable {
    ataraxia.containers.media-stack.caddy = mkDefault true;
    ataraxia.containers.media-stack.jackett = mkDefault true;
    ataraxia.containers.media-stack.jellyfin = mkDefault true;
    ataraxia.containers.media-stack.kavita = mkDefault true;
    ataraxia.containers.media-stack.lidarr = mkDefault true;
    ataraxia.containers.media-stack.medusa = mkDefault true;
    ataraxia.containers.media-stack.qbittorrent = mkDefault true;
    ataraxia.containers.media-stack.radarr = mkDefault true;
    ataraxia.containers.media-stack.recyclarr = mkDefault true;
    ataraxia.containers.media-stack.sonarr = mkDefault true;

    systemd.services."podman-create-${pod-name}" =
      let
        portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
        start = pkgs.writeShellScript "create-pod-${pod-name}" ''
          podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping} --dns ${pod-dns}
        '';
        stop = pkgs.writeShellScript "remove-pod-${pod-name}" ''
          podman pod rm -i -f ${pod-name}
        '';
      in
      rec {
        path = [
          pkgs.coreutils
          config.virtualisation.podman.package
        ];
        before =
          [ ]
          ++ optionals cfg.caddy [ "${backend}-media-caddy.service" ]
          ++ optionals cfg.jackett [ "${backend}-jackett.service" ]
          ++ optionals cfg.jellyfin [ "${backend}-jellyfin.service" ]
          ++ optionals cfg.kavita [ "${backend}-kavita.service" ]
          ++ optionals cfg.lidarr [ "${backend}-lidarr.service" ]
          ++ optionals cfg.medusa [ "${backend}-medusa.service" ]
          ++ optionals cfg.qbittorrent [ "${backend}-qbittorrent.service" ]
          ++ optionals cfg.radarr [ "${backend}-radarr.service" ]
          ++ optionals cfg.recyclarr [ "${backend}-recyclarr.service" ]
          ++ optionals cfg.sonarr [ "${backend}-sonarr.service" ];
        requiredBy = before;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = start;
          ExecStop = stop;
        };
      };
  };
}
