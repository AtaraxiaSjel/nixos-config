{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool;
  inherit (config.virtualisation.quadlet) networks;

  cfg = config.ataraxia.containers.filestash;
  nginx = config.ataraxia.services.nginx;
  nas-path = "/media/nas/media-stack";
  domain = "files.ataraxiadev.com";
  port = "8334";
in
{
  options.ataraxia.containers.filestash = {
    enable = mkEnableOption "Enable filestash container";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.filestash = {
      autoStart = true;
      containerConfig = {
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
          APPLICATION_URL = domain;
          CANARY = "true";
        };
        # Tags: latest
        image = "docker.io/machines/filestash@sha256:9f2df9dc6d8a73e793a8907f3fe83c2e4574deb5db2959032720abb614fcd601";
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:${port}:${port}/tcp" ];
        volumes = [
          "${nas-path}/configs/filestash:/app/data/state"
          "${nas-path}:/mnt"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${port}";
          proxyWebsockets = true;
          extraConfig = ''
            allow 127.0.0.1/32;
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            allow fd7a:115c:a1e0::/64;
            deny all;
            proxy_busy_buffers_size 1024k;
            proxy_buffers 32 1024k;
            proxy_buffer_size 1024k;
            proxy_read_timeout 86400;
          '';
        };
      };
    };
  };
}
