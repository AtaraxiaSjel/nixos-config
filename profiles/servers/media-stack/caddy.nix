{ config, lib, pkgs, ... }:
let
  caddyconf = pkgs.writeText "Caddyfile" ''
    {
      auto_https off
      http_port 8080
      log {
        output file /config/logs/access.log
      }
    }
    jellyfin.ataraxiadev.com:8080 {
      reverse_proxy jellyfin:8096
    }
    radarr.ataraxiadev.com:8080 {
      reverse_proxy radarr:7878
    }
    qbit.ataraxiadev.com:8080 {
      reverse_proxy qbittorrent:8080
    }
    prowlarr.ataraxiadev.com:8080 {
      reverse_proxy prowlarr:9696
    }
    sonarr.ataraxiadev.com:8080 {
      reverse_proxy sonarr-anime:8989
    }
    sonarrtv.ataraxiadev.com:8080 {
      reverse_proxy sonarr-tv:8989
    }
    organizr.ataraxiadev.com:8080 {
      reverse_proxy organizr:80
    }
    lidarr.ataraxiadev.com:8080 {
      reverse_proxy lidarr:8686
    }
    bazarr.ataraxiadev.com:8080 {
      reverse_proxy bazarr:6767
    }
  '';
in {
  virtualisation.oci-containers.containers.media-caddy = {
    autoStart = true;
    environment = {
      PUID = "1009";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    ports = [ "127.0.0.1:8100:8080" ];
    image = "cr.hotio.dev/hotio/caddy:release-2.4.6";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/caddy/config:/config"
      "${caddyconf}:/config/Caddyfile"
    ];
  };
}