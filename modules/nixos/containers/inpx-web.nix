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

  cfg = config.ataraxia.containers.inpx-web;
  nginx = config.ataraxia.services.nginx;
  nas-path = "/media/nas/media-stack";
  domain = "books.ataraxiadev.com";
in
{
  options.ataraxia.containers.inpx-web = {
    enable = mkEnableOption "Enable inpx-web container";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.inpx-web = {
      autoStart = true;
      containerConfig = {
        user = "1000:100";
        # Tags: latest, master
        image = "ghcr.io/ataraxiasjel/inpx-web@sha256:54a2112aa9b546c23a7e4e9b662d16295adaf5cc67d722ad58271f9a0b1274e4";
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:${ports.inpx-web.str}:12380/tcp" ];
        volumes = [
          "${nas-path}/torrents/other/flibusta:/library:ro"
          "${nas-path}/configs/inpx-web:/app/data"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.inpx-web.str}";
          proxyWebsockets = true;
          extraConfig = ''
            allow 127.0.0.1/32;
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            allow fd7a:115c:a1e0::/64;
            deny all;

            auth_request /tinyauth;
            error_page 401 = @tinyauth_login;
          '';
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${nas-path}/configs/inpx-web 0755 1000 100 -"
    ];
  };
}
