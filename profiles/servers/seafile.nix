{ config, lib, pkgs, ... }:
with config.users.users.alukard; with config.users.groups.${group}; {
  secrets.db-pass = { };
  secrets.seafile-admin-pass = { };

  virtualisation.oci-containers.containers.seafile-server = {
    autoStart = true;
    dependsOn = [ "seafile-db" "memcached" "seafile-caddy" ];
    environment = {
      DB_HOST = "seafile-db";
      TIME_ZONE = "Europe/Moscow";
      HTTPS = "false";
      SEAFILE_SERVER_HOSTNAME = "file.ataraxiadev.com";
    };
    environmentFiles = [
      config.secrets.db-pass.decrypted
    ];
    extraOptions = [
      "--network=seafile"
    ];
    image = "ggogel/seafile-server:9.0.4";
    volumes = [ "/seafile/server-data:/shared" ];
  };

  virtualisation.oci-containers.containers.seahub = {
    autoStart = true;
    dependsOn = [ "seafile-server" "seahub-media" "seafile-caddy" ];
    environment = {
      SEAFILE_ADMIN_EMAIL = "admin@ataraxiadev.com";
    };
    environmentFiles = [
      config.secrets.seafile-admin-pass.decrypted
    ];
    extraOptions = [
      "--network=seafile"
    ];
    image = "ggogel/seahub:9.0.4";
    volumes = [
      "/seafile/server-data:/shared"
    ];
  };

  virtualisation.oci-containers.containers.seahub-media = {
    autoStart = true;
    dependsOn = [ "seafile-caddy" ];
    extraOptions = [
      "--network=seafile"
    ];
    image = "ggogel/seahub-media:9.0.4";
    volumes = [
      "/seafile/server-data/seafile/seahub-data/avatars:/usr/share/caddy/media/avatars"
      "/seafile/server-data/seafile/seahub-data/custom:/usr/share/caddy/media/custom"
    ];
  };

  virtualisation.oci-containers.containers.seafile-db = {
    autoStart = true;
    environment = {
      MYSQL_LOG_CONSOLE = "true";
    };
    environmentFiles = [
      config.secrets.db-pass.decrypted
    ];
    extraOptions = [
      "--network=seafile"
    ];
    image = "mariadb:10.7.1";
    volumes = [
      "/seafile/mariadb:/var/lib/mysql"
    ];
  };

  virtualisation.oci-containers.containers.memcached = {
    autoStart = true;
    environment = {
      MEMCACHED_CACHE_SIZE = "128";
    };
    extraOptions = [
      "--network=seafile"
    ];
    image = "bitnami/memcached:1.6.14";
  };

  virtualisation.oci-containers.containers.seafile-caddy = {
    autoStart = true;
    extraOptions = [
      "--network=seafile"
    ];
    ports = [ "127.0.0.1:8088:80" ];
    image = "ggogel/seafile-caddy:1.0.6";
  };

  systemd.services.create-seafile-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-seafile-server.service"
      "${backend}-seahub.service"
      "${backend}-seahub-media.service"
      "${backend}-seafile-db.service"
      "${backend}-memcached.service"
      "${backend}-seafile-caddy.service"
    ];
    script = ''
      ${pkgs.docker}/bin/docker network inspect seafile || \
        ${pkgs.docker}/bin/docker network create -d bridge seafile
      exit 0
    '';
  };
}
