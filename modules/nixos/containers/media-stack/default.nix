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
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.media-stack;
  networks = config.virtualisation.quadlet.networks;
  nginx = config.ataraxia.services.nginx;
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
        networks = [ networks.br-services.ref ];
        publishPorts = [
          # caddy
          "127.0.0.1:${ports.jackett.str}:9117/tcp"
          "127.0.0.1:${ports.jellyfin.str}:8096/tcp"
          "127.0.0.1:${ports.kavita.str}:5000/tcp"
          "127.0.0.1:${ports.lidarr.str}:8686/tcp"
          "127.0.0.1:${ports.medusa.str}:8081/tcp"
          "127.0.0.1:${ports.qbittorrent.str}:8080/tcp"
          "127.0.0.1:${ports.radarr.str}:7878/tcp"
          "127.0.0.1:${ports.sonarr.str}:8989/tcp"
          # qbittorrent
          "0.0.0.0:7000:7000/tcp"
          "0.0.0.0:7000:7000/udp"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      "jackett.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.jackett.str}";
          proxyWebsockets = true;
        };
      };
      "kavita.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.kavita.str}";
          proxyWebsockets = true;
        };
      };
      "lidarr.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.lidarr.str}";
          proxyWebsockets = true;
        };
      };
      "qbit.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.qbittorrent.str}";
          proxyWebsockets = true;
        };
      };
      "radarr.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.radarr.str}";
          proxyWebsockets = true;
        };
      };
      "sonarr.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.sonarr.str}";
          proxyWebsockets = true;
        };
      };
      "prowlarr.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.prowlarr.str}";
          proxyWebsockets = true;
        };
      };
      "jellyfin.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.jellyfin.str}";
          extraConfig = ''
            proxy_buffering off;
          '';
        };
        locations."/socket" = {
          proxyPass = "http://127.0.0.1:${ports.jellyfin.str}";
          proxyWebsockets = true;
        };
        extraConfig = ''
          client_max_body_size 50M;
        '';
      };
      "medusa.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.medusa.str}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
