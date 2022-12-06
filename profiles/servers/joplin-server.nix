{ config, lib, pkgs, ... }:
let
  joplin-data = "/srv/joplin/data";
  joplin-uid = "1001";
  backend = config.virtualisation.oci-containers.backend;
in {
  secrets.joplin-env = { };
  secrets.joplin-db-env = { };

  virtualisation.oci-containers.containers = {
    joplin = {
      autoStart = true;
      dependsOn = [ "joplin-db" ];
      environmentFiles = [ config.secrets.joplin-env.decrypted ];
      extraOptions = [
        "--network=joplin"
      ];
      ports = [ "127.0.0.1:22300:22300" ];
      image = "ataraxiadev/joplin-server:2.8.8";
      volumes = [ "${joplin-data}:/home/joplin/data" ];
    };
    joplin-db = {
      autoStart = true;
      environmentFiles = [ config.secrets.joplin-db-env.decrypted ];
      extraOptions = [
        "--network=joplin"
      ];
      image = "postgres:13";
      volumes = [ "/srv/joplin/postgres:/var/lib/postgresql/data" ];
    };
  };
  systemd.services.create-joplin-network = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-joplin.service"
      "${backend}-joplin-db.service"
    ];
    script = ''
      ${pkgs.docker}/bin/docker network inspect joplin || \
        ${pkgs.docker}/bin/docker network create -d bridge joplin
      exit 0
    '';
  };
  systemd.services.create-joplin-folder = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "${backend}-joplin.service" ];
    script = ''
      [ ! -d "${joplin-data}" ] && mkdir -p ${joplin-data} && chown ${joplin-uid} ${joplin-data}
    '';
  };
}