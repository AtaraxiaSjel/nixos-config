{ pkgs, ... }:
let
  nas-path = "/media/nas/media-stack";
  caddyconf = pkgs.writeText "Caddyfile" ''
    {
      auto_https off
      http_port 8180
    }
    jellyfin.ataraxiadev.com:8180 {
      reverse_proxy jellyfin:8096
    }
    qbit.ataraxiadev.com:8180 {
      reverse_proxy qbittorrent:8080
    }
    medusa.ataraxiadev.com:8180 {
      reverse_proxy medusa:8081
    }
    jackett.ataraxiadev.com:8180 {
      reverse_proxy jackett:9117
    }
    sonarr.ataraxiadev.com:8180 {
      reverse_proxy sonarr:8989
    }
    radarr.ataraxiadev.com:8180 {
      reverse_proxy radarr:7878
    }
    lidarr.ataraxiadev.com:8180 {
      reverse_proxy lidarr:8686
    }
    kavita.ataraxiadev.com:8180 {
      reverse_proxy kavita:5000
    }
  '';
in {
  virtualisation.oci-containers.containers.media-caddy = {
    autoStart = true;
    image = "ghcr.io/hotio/caddy:release-2.8.4";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    volumes = [
      "${nas-path}/configs/caddy:/config"
      "${caddyconf}:/config/Caddyfile"
    ];
  };
}