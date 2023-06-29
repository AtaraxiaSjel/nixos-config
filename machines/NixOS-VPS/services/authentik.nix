{ config, pkgs, lib, inputs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  data-dir = "/srv/authentik";
  pod-name = "authentik-pod";
  open-ports = [
    # authentik
    "127.0.0.1:9000:9000/tcp" "127.0.0.1:9443:9443/tcp"
    # ldap
    "127.0.0.1:389:3389/tcp" "127.0.0.1:636:6636/tcp"
  ];
  owner = "1000";
  authentik-version = "2023.5.4";
in {
  services.nginx.virtualHosts."auth.ataraxiadev.com" = {
    forceSSL = true;
    enableACME = false;
    useACMEHost = "wg.ataraxiadev.com";
    locations."/" = {
      proxyPass = "http://127.0.0.1:9000";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
      '';
    };
  };


  virtualisation.oci-containers.containers = {
    authentik-postgresql = {
      autoStart = true;
      image = "docker.io/library/postgres:12-alpine";
      extraOptions = [ "--pod=${pod-name}" ];
      environmentFiles = [ "${data-dir}/env" ];
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
      image = "ghcr.io/goauthentik/server:${authentik-version}";
      cmd = [ "server" ];
      extraOptions = [ "--pod=${pod-name}" ];
      environment = {
        AUTHENTIK_REDIS__HOST = "authentik-redis";
        AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
      };
      environmentFiles = [ "${data-dir}/env" ];
      volumes = [
        "${data-dir}/media:/media"
        "${data-dir}/custom-templates:/templates"
      ];
    };
    authentik-worker = {
      autoStart = true;
      dependsOn = [ "authentik-server" ];
      image = "ghcr.io/goauthentik/server:${authentik-version}";
      cmd = [ "worker" ];
      extraOptions = [ "--pod=${pod-name}" ];
      environment = {
        AUTHENTIK_REDIS__HOST = "authentik-redis";
        AUTHENTIK_POSTGRESQL__HOST = "authentik-postgresql";
      };
      environmentFiles = [ "${data-dir}/env" ];
      # user = "root";
      volumes = [
        # "/var/run/${backend}/${backend}.sock"
        "${data-dir}/media:/media"
        "${data-dir}/certs:/certs"
        "${data-dir}/custom-templates:/templates"
      ];
    };
    authentik-ldap = {
      autoStart = true;
      dependsOn = [ "authentik-server" ];
      image = "ghcr.io/goauthentik/ldap:${authentik-version}";
      extraOptions = [ "--pod=${pod-name}" ];
      environment = {
        AUTHENTIK_HOST = "https://auth.ataraxiadev.com";
        AUTHENTIK_INSECURE = "false";
      };
      environmentFiles = [ "${data-dir}/ldap" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${data-dir}/db 0700 70 root -"
    "d ${data-dir}/redis 0755 999 root -"
    "d ${data-dir}/media 0755 ${owner} ${owner} -"
    "d ${data-dir}/certs 0755 ${owner} ${owner} -"
    "d ${data-dir}/custom-templates 0755 ${owner} ${owner} -"
  ];

  systemd.services."podman-create-${pod-name}" = let
    portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
    start = pkgs.writeShellScript "create-pod" ''
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
      "${backend}-authentik-ldap.service"
    ];
    requiredBy = before;
    partOf = before;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = start;
      ExecStop = stop;
    };
  };
}