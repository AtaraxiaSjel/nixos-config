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
    ./jellyfin.nix
    ./kavita.nix
    ./lidarr.nix
    ./medusa.nix
    ./navidrome.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./recyclarr.nix
    ./sonarr.nix
    ./tubearchivist.nix
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
    ataraxia.containers.media-stack.jellyfin = mkDefault true;
    ataraxia.containers.media-stack.kavita = mkDefault true;
    ataraxia.containers.media-stack.lidarr = mkDefault true;
    ataraxia.containers.media-stack.medusa = mkDefault true;
    ataraxia.containers.media-stack.navidrome = mkDefault true;
    ataraxia.containers.media-stack.prowlarr = mkDefault true;
    ataraxia.containers.media-stack.qbittorrent = mkDefault true;
    ataraxia.containers.media-stack.radarr = mkDefault true;
    ataraxia.containers.media-stack.recyclarr = mkDefault true;
    ataraxia.containers.media-stack.sonarr = mkDefault true;
    ataraxia.containers.media-stack.tubearchivist = mkDefault true;

    virtualisation.quadlet.pods.media-stack = {
      podConfig = {
        networks = [
          networks.br-services.ref
          networks.lldap.ref
        ];
        publishPorts = [
          "127.0.0.1:${ports.jellyfin.str}:8096/tcp"
          "127.0.0.1:${ports.kavita.str}:5000/tcp"
          "127.0.0.1:${ports.lidarr.str}:8686/tcp"
          "127.0.0.1:${ports.medusa.str}:8081/tcp"
          "127.0.0.1:${ports.qbittorrent.str}:8080/tcp"
          "127.0.0.1:${ports.radarr.str}:7878/tcp"
          "127.0.0.1:${ports.sonarr.str}:8989/tcp"
          "127.0.0.1:${ports.prowlarr.str}:9696/tcp"
          "127.0.0.1:${ports.navidrome.str}:4533/tcp"
          "127.0.0.1:${ports.tubearchivist.str}:8000/tcp"
          # qbittorrent
          "0.0.0.0:7000:7000/tcp"
          "0.0.0.0:7000:7000/udp"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
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
      "music.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.navidrome.str}";
          proxyWebsockets = true;
          extraConfig = ''
            auth_request /tinyauth;
            error_page 401 = @tinyauth_login;
            auth_request_set $tinyauth_remote_user $upstream_http_remote_user;
            proxy_set_header Remote-User $tinyauth_remote_user;
          '';
        };
        locations."/share" = {
          proxyPass = "http://127.0.0.1:${ports.navidrome.str}";
        };
        locations."/rest" = {
          proxyPass = "http://127.0.0.1:${ports.navidrome.str}";
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
      "tube.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.tubearchivist.str}";
          proxyWebsockets = true;
          # extraConfig = ''
          #   auth_request /tinyauth;
          #   error_page 401 = @tinyauth_login;
          #   auth_request_set $tinyauth_remote_user $upstream_http_remote_user;
          #   proxy_set_header Remote-User $tinyauth_remote_user;
          # '';
        };
      };
    };
  };
}
