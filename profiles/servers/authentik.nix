{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  data-dir = "/srv/authentik";
  pod-name = "authentik-pod";
  open-ports = [ "127.0.0.1:9000:9000/tcp" "127.0.0.1:9443:9443/tcp" ];
  owner = "1000";
in {
  secrets.authentik-env = { };

  virtualisation.oci-containers.containers = {
    authentik-postgresql = {
      autoStart = true;
      image = "docker.io/library/postgres:12-alpine";
      extraOptions = [ "--pod=${pod-name}" ];
      environmentFiles = [ config.secrets.authentik-env.decrypted ];
      volumes = [
        "${data-dir}/db:/var/lib/postgresql/data"
      ];
    };
    authentik-redis = {
      autoStart = true;
      image = "docker.io/library/redis:alpine";
      cmd = [ "--save" "60" "1" "--loglevel" "warning" ];
      extraOptions = [ "--pod=${pod-name}" ];
      volumes = [
        "${data-dir}/redis:/data"
      ];
    };
    authentik-server = {
      autoStart = true;
      dependsOn = [ "authentik-postgresql" "authentik-redis" ];
      image = "ghcr.io/goauthentik/server:2023.1.2";
      cmd = [ "server" ];
      extraOptions = [ "--pod=${pod-name}" ];
      environment = {
        AUTHENTIK_REDIS__HOST = "authentik-redis";
        AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
      };
      environmentFiles = [ config.secrets.authentik-env.decrypted ];
      volumes = [
        "${data-dir}/media:/media"
        "${data-dir}/custom-templates:/templates"
      ];
    };
    authentik-worker = {
      autoStart = true;
      dependsOn = [ "authentik-server" ];
      image = "ghcr.io/goauthentik/server:2023.1.2";
      cmd = [ "worker" ];
      extraOptions = [ "--pod=${pod-name}" ];
      environment = {
        AUTHENTIK_REDIS__HOST = "authentik-redis";
        AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
      };
      environmentFiles = [ config.secrets.authentik-env.decrypted ];
      # user = "root";
      volumes = [
        # "/var/run/${backend}/${backend}.sock"
        "${data-dir}/media:/media"
        "${data-dir}/certs:/certs"
        "${data-dir}/custom-templates:/templates"
      ];
    };
  };

  systemd.services."podman-create-${pod-name}" = let
    portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
    start = pkgs.writeShellScript "create-pod" ''
      if [[ ! -d "${data-dir}" ]]; then
        mkdir -p "${data-dir}/db"
        mkdir -p "${data-dir}/redis"
        mkdir -p "${data-dir}/media" && chown ${owner}:${owner} "${data-dir}/media"
        mkdir -p "${data-dir}/certs" && chown ${owner}:${owner} "${data-dir}/certs"
        mkdir -p "${data-dir}/custom-templates" && chown ${owner}:${owner} "${data-dir}/custom-templates"
      fi
      podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping}
    '';
    stop = "podman pod rm -i -f ${pod-name}";
  in rec {
    path = [ pkgs.coreutils config.virtualisation.podman.package ];
    before = [
      "${backend}-authentik-postgresql.service"
      "${backend}-authentik-redis.service"
      "${backend}-authentik-server.service"
      "${backend}-authentik-worker.service"
    ];
    wantedBy = before;
    partOf = before;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = start;
      ExecStop = stop;
    };
  };
}