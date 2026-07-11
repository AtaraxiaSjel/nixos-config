{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool;
  inherit (config.ataraxia.lists) ports users;

  cfg = config.ataraxia.containers.home-assistant;
  nginx = config.ataraxia.services.nginx;
  domain = "hass.ataraxiadev.com";
in
{
  options.ataraxia.containers.home-assistant = {
    enable = mkEnableOption "Enable home-assistant container";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.home-assistant = {
      autoStart = true;
      containerConfig = {
        environments.TZ = "Europe/Moscow";
        user = "${users.hass-oci.uidStr}:${users.hass-oci.gidStr}";
        # Tags: stable, rc, beta
        image = "docker.io/homeassistant/home-assistant@sha256:adb3341e31e03e0048e60d8c1cf952e118a381ae258bb921d3da12a3b27bf0c2";
        networks = [ "host" ];
        # publishPorts = [ "127.0.0.1:${ports.home-assistant.str}:8123/tcp" ];
        volumes = [
          "/srv/home-assistant:/config"
          "/run/dbus:/run/dbus:ro"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.home-assistant.str}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };

    users.users.${users.hass-oci.name} = {
      isSystemUser = true;
      group = users.hass-oci.name;
      uid = users.hass-oci.uid;
    };
    users.groups.${users.hass-oci.name}.gid = users.hass-oci.gid;

    systemd.tmpfiles.rules = [
      "d /srv/home-assistant 0700 ${users.hass-oci.uidStr} ${users.hass-oci.gidStr} -"
    ];
  };
}
