{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/containers";
  pod-name = "homepage-pod";
  pod-dns = "192.168.0.1";
  open-ports = [
    "127.0.0.1:3000:3000/tcp"
  ];
in {
  virtualisation.oci-containers.containers = {
    homepage = {
      autoStart = true;
      image = "ghcr.io/gethomepage/homepage:v0.8.0";
      environment = {
        PUID = "1000";
        PGID = "100";
      };
      extraOptions = [ "--pod=${pod-name}" ];
      volumes = [
        "${nas-path}/homepage/config:/app/config"
        "${nas-path}/homepage/icons:/app/public/icons"
        "${nas-path}/homepage/images:/app/public/images"
      ];
    };
    docker-proxy = {
      autoStart = true;
      image = "ghcr.io/tecnativa/docker-socket-proxy:0.1.1";
      environment = {
        CONTAINERS = "1";
        SERVICES = "0";
        TASKS = "0";
        POST = "0";
      };
      extraOptions = [ "--pod=${pod-name}" ];
      volumes = [
        "${nas-path}/homepage/config:/app/config"
        "${nas-path}/homepage/icons:/app/public/icons"
        "${nas-path}/homepage/images:/app/public/images"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${nas-path}/homepage/config 0755 1000 100 -"
    "d ${nas-path}/homepage/icons 0755 1000 100 -"
    "d ${nas-path}/homepage/images 0755 1000 100 -"
  ];

  systemd.services."podman-create-${pod-name}" = let
    portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
    start = pkgs.writeShellScript "create-pod-${pod-name}" ''
      podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping} --dns ${pod-dns}
    '';
    stop = "podman pod rm -i -f ${pod-name}";
  in rec {
    path = [ pkgs.coreutils config.virtualisation.podman.package ];
    before = [
      "${backend}-homepage.service"
      "${backend}-docker-proxy.service"
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