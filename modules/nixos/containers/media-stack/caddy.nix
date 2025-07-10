{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

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
in
{
  options.ataraxia.containers.media-stack = {
    caddy = mkEnableOption "Enable media-caddy container";
  };

  config = mkIf cfg.caddy {
    virtualisation.quadlet.containers.caddy = {
      autoStart = true;
      containerConfig = {
        # Tags: release-20b7f25, release-2.10.0, release
        image = "ghcr.io/hotio/caddy@sha256:937fe02672e7ce7f189e28d45c4ccfe86b2a7d5791b4e04badb55e143e32d5b7";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/caddy:/config"
          "${caddyconf}:/config/Caddyfile"
        ];
      };
    };
  };
}
