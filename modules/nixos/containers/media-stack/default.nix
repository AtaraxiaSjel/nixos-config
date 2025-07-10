{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool;

  cfg = config.ataraxia.containers.media-stack;
  networks = config.virtualisation.quadlet.networks;
  nginx = config.ataraxia.services.nginx;

  caddy-port = "8180";
  # TODO: fix caddy for medusa. Maybe change to something else
  medusa-port = "8180";
  open-ports = [
    # caddy
    "127.0.0.1:${caddy-port}:${caddy-port}"
    "127.0.0.1:${medusa-port}:${medusa-port}"
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
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
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

    virtualisation.quadlet.pods.media-stack = {
      podConfig = {
        dns = [ pod-dns ];
        networks = [ networks.br-services.ref ];
        publishPorts = open-ports;
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      "media-stack" = recursiveUpdate nginx.defaultSettings {
        serverAliases = [
          "jackett.ataraxiadev.com"
          "kavita.ataraxiadev.com"
          "lidarr.ataraxiadev.com"
          "qbit.ataraxiadev.com"
          "radarr.ataraxiadev.com"
          "sonarr.ataraxiadev.com"
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:${caddy-port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            send_timeout 15m;
            proxy_connect_timeout 600;
            proxy_send_timeout 600;
            proxy_read_timeout 15m;
          '';
        };
      };
      "jellyfin.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${caddy-port}";
          extraConfig = ''
            proxy_buffering off;
          '';
        };
        locations."/socket" = {
          proxyPass = "http://127.0.0.1:${caddy-port}";
          proxyWebsockets = true;
        };
        extraConfig = ''
          client_max_body_size 50M;
        '';
      };
      "medusa.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${medusa-port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
