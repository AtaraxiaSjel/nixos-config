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
        # updater: track=stable
        # Tags: stable, latest, 2026.9.2
        image = "docker.io/homeassistant/home-assistant@sha256:a1bc133af84ee6505fe2c266d9805b7c75b780dfdc188edfee3b11e8f3cd8efe";
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
