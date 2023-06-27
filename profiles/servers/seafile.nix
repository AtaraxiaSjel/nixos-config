{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/seafile";
  pod-name = "seafile";
  open-ports = [ "127.0.0.1:8088:80" ];
  seahub-media-caddyfile = pkgs.writeText "Caddyfile" ''
    {
        admin off
        http_port 8098
        https_port 8099
    }
    :8098 {
        root * /usr/share/caddy
        file_server
    }
  '';
  seafile-caddy-caddyfile = pkgs.writeText "Caddyfile" ''
    {
        auto_https disable_redirects
    }

    http:// https:// {
        reverse_proxy seahub:8000 {
            lb_policy header X-Forwarded-For
            trusted_proxies private_ranges
        }
        handle_path /seafhttp* {
            uri strip_prefix seafhttp
            reverse_proxy seafile-server:8082 {
                    trusted_proxies private_ranges
            }
        }
        reverse_proxy /seafdav* seafile-server:8080 {
            header_up Destination https:// http://
            trusted_proxies private_ranges
        }
        reverse_proxy /media/* seahub-media:8098 {
            lb_policy header X-Forwarded-For
            trusted_proxies private_ranges
        }
    }
  '';
in {
  secrets.seafile-db-pass = { };
  secrets.seafile-admin-pass = { };

  virtualisation.oci-containers.containers.seafile-server = {
    autoStart = true;
    dependsOn = [ "seafile-db" "memcached" "seafile-caddy" ];
    environment = {
      DB_HOST = "seafile-db";
      TIME_ZONE = "Europe/Moscow";
      HTTPS = "true";
      SEAFILE_SERVER_HOSTNAME = "file.ataraxiadev.com";
      GC_CRON = "0 6 * * 0";
    };
    environmentFiles = [
      config.secrets.seafile-db-pass.decrypted
    ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/ggogel/seafile-server:9.0.10";
    volumes = [ "${nas-path}/server-data:/shared" ];
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
      "--pod=seafile"
      # "--add-host=auth.ataraxiadev:192.168.0.10"
    ];
    image = "docker.io/ggogel/seahub:9.0.10";
    volumes = [
      "${nas-path}/server-data:/shared"
    ];
  };

  virtualisation.oci-containers.containers.seahub-media = {
    autoStart = true;
    dependsOn = [ "seafile-caddy" ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/ggogel/seahub-media:9.0.10";
    volumes = [
      "${seahub-media-caddyfile}:/etc/caddy/Caddyfile"
      "${nas-path}/server-data/seafile/seahub-data/avatars:/usr/share/caddy/media/avatars"
      "${nas-path}/server-data/seafile/seahub-data/custom:/usr/share/caddy/media/custom"
    ];
  };

  virtualisation.oci-containers.containers.seafile-db = {
    autoStart = true;
    environment = {
      MYSQL_LOG_CONSOLE = "true";
    };
    environmentFiles = [
      config.secrets.seafile-db-pass.decrypted
    ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/mariadb:10.7.8";
    volumes = [
      "${nas-path}/db:/var/lib/mysql"
    ];
  };

  virtualisation.oci-containers.containers.memcached = {
    autoStart = true;
    cmd = [ "memcached" "-m 256" ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/memcached:1.6.18";
  };

  virtualisation.oci-containers.containers.seafile-caddy = {
    autoStart = true;
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/ggogel/seafile-caddy:1.0.8";
    volumes = [ "${seafile-caddy-caddyfile}:/etc/caddy/Caddyfile" ];
  };

  systemd.services."podman-create-${pod-name}" = let
    portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
    start = pkgs.writeShellScript "create-pod" ''
      podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping}
      exit 0
    '';
  in rec {
    path = [ pkgs.coreutils config.virtualisation.podman.package ];
    before = [
      "${backend}-seafile-server.service"
      "${backend}-seahub.service"
      "${backend}-seahub-media.service"
      "${backend}-seafile-db.service"
      "${backend}-memcached.service"
      "${backend}-seafile-caddy.service"
    ];
    requiredBy = before;
    partOf = before;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = start;
    };
  };
}
