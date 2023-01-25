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
  # systemd.services.create-joplin-network = with config.virtualisation.oci-containers; {
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [
  #     "${backend}-joplin.service"
  #     "${backend}-joplin-db.service"
  #   ];
  #   script = ''
  #     ${pkgs.podman}/bin/podman network inspect joplin || \
  #       ${pkgs.podman}/bin/podman network create -d bridge joplin || true
  #   '';
  # };
  systemd.services.podman-joplin = {
    path = [ "/run/wrappers" ];
    serviceConfig.User = config.mainuser;
    preStart = "${pkgs.podman}/bin/podman network create -d bridge joplin || true";
    postStop = "${pkgs.podman}/bin/podman network rm joplin || true";
  };
  systemd.services.podman-joplin-db = {
    path = [ "/run/wrappers" ];
    serviceConfig.User = config.mainuser;
    preStart = "${pkgs.podman}/bin/podman network create -d bridge joplin || true";
    postStop = "${pkgs.podman}/bin/podman network rm joplin || true";
  };
  systemd.services.create-joplin-folder = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "${backend}-joplin.service" ];
    script = ''
      [ ! -d "${joplin-data}" ] && mkdir -p ${joplin-data} && chown ${joplin-uid} ${joplin-data}
    '';
  };
}