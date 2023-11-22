{ config, lib, pkgs, ... }:
let
  joplin-data = "/srv/joplin/data";
  joplin-db-data = "/srv/joplin/postgres";
  joplin-uid = "1001";
  backend = config.virtualisation.oci-containers.backend;
  pod-name = "joplin-pod";
  open-ports = [ "127.0.0.1:22300:22300/tcp" ];
in {
  secrets.joplin-env = { };
  secrets.joplin-db-env = { };

  # FIXMEL mailer
  virtualisation.oci-containers.containers = {
    joplin = {
      autoStart = true;
      dependsOn = [ "joplin-db" ];
      environment = { MAX_TIME_DRIFT = "0"; };
      environmentFiles = [ config.secrets.joplin-env.decrypted ];
      extraOptions = [ "--pod=${pod-name}" ];
      image = "docker.io/ataraxiadev/joplin-server:2.9.17";
      volumes = [
        "${joplin-data}:/home/joplin/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };
    joplin-db = {
      autoStart = true;
      environmentFiles = [ config.secrets.joplin-db-env.decrypted ];
      extraOptions = [ "--pod=${pod-name}" ];
      image = "docker.io/postgres:13";
      volumes = [ "${joplin-db-data}:/var/lib/postgresql/data" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${joplin-data} 0755 ${joplin-uid} ${joplin-uid} -"
    "d ${joplin-db-data} 0700 dhcpcd dhcpcd -"
  ];

  systemd.services."podman-create-${pod-name}" = let
    portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
    start = pkgs.writeShellScript "create-pod-${pod-name}" ''
      podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping}
    '';
    stop = "podman pod rm -i -f ${pod-name}";
  in rec {
    path = [ pkgs.coreutils config.virtualisation.podman.package ];
    before = [ "${backend}-joplin.service" "${backend}-joplin-db.service" ];
    requiredBy = before;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = start;
      ExecStop = stop;
    };
  };
}