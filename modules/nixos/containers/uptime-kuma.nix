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
  inherit (config.ataraxia.lists) ports users;

  cfg = config.ataraxia.containers.uptime-kuma;
  nginx = config.ataraxia.services.nginx;
  domain = "uptime.ataraxiadev.com";
in
{
  options.ataraxia.containers.uptime-kuma = {
    enable = mkEnableOption "Enable uptime-kuma container";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.uptime-kuma = {
      autoStart = true;
      containerConfig = {
        user = "${users.uptime-kuma.uidStr}:${users.uptime-kuma.gidStr}";
        # Tags: 2.0.1-slim-rootless, 2-slim-rootless
        image = "docker.io/louislam/uptime-kuma@sha256:b9bcd3c91183ef8fa7ab4758d0dc95cf790837c25e5e4bbc36f171db2b0d4f96";
        networks = [
          networks.br-services.ref
          networks.dockerproxy.ref
        ];
        publishPorts = [ "127.0.0.1:${ports.uptime-kuma.str}:3001/tcp" ];
        volumes = [
          "/srv/uptime-kuma/data:/app/data"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.uptime-kuma.str}";
          proxyWebsockets = true;
        };
      };
    };

    users.users.${users.uptime-kuma.name} = {
      isSystemUser = true;
      group = users.uptime-kuma.name;
      uid = users.uptime-kuma.uid;
    };
    users.groups.${users.uptime-kuma.name}.gid = users.uptime-kuma.gid;

    systemd.tmpfiles.rules = [
      "d /srv/uptime-kuma 0700 ${users.uptime-kuma.uidStr} ${users.uptime-kuma.gidStr} -"
      "d /srv/uptime-kuma/data 0700 ${users.uptime-kuma.uidStr} ${users.uptime-kuma.gidStr} -"
    ];
  };
}
