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
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.filestash;
  nginx = config.ataraxia.services.nginx;
  nas-path = "/media/nas/media-stack";
  domain = "files.ataraxiadev.com";
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
        image = "docker.io/machines/filestash@sha256:5ae8e712b3c4b0635ade204093a9f6bcdaaf24b6e2d30d4fd9d8067f3216efb3";
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:${ports.filestash.str}:8334/tcp" ];
        volumes = [
          "${nas-path}/configs/filestash:/app/data/state"
          "${nas-path}:/mnt"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.filestash.str}";
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

            auth_request /tinyauth;
            error_page 401 = @tinyauth_login;
          '';
        };
      };
    };
  };
}
