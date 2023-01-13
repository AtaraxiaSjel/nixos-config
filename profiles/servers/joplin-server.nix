{ config, lib, pkgs, ... }:
let
  joplin-data = "/srv/joplin/data";
  joplin-db-data = "/srv/joplin/postgres";
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
        "--pod=joplin"
        # "--network=joplin"
      ];
      # ports = [ "127.0.0.1:22300:22300" ];
      image = "docker.io/library/ataraxiadev/joplin-server:2.9.17";
      volumes = [ "${joplin-data}:/home/joplin/data" ];
    };
    joplin-db = {
      autoStart = true;
      environmentFiles = [ config.secrets.joplin-db-env.decrypted ];
      extraOptions = [
        "--pod=joplin"
        # "--network=joplin"
      ];
      image = "docker.io/library/postgres:13";
      volumes = [ "${joplin-db-data}:/var/lib/postgresql/data" ];
    };
  };
  systemd.services.podman-create-pod-joplin = let
    podman = config.virtualisation.podman.package;
    # start-script = pkgs.writeShellScript "start" ''
    # '';
  in {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = ''
        mkdir -p ${joplin-data} && chown ${joplin-uid} ${joplin-data}
        mkdir -p ${joplin-db-data}
        ${podman}/bin/podman pod exists joplin ||
          ${podman}/bin/podman pod create -n joplin -p "127.0.0.1:22300:22300"
      '';
      ExecStop = "${podman}/bin/podman pod rm -i -f joplin";
    };
    wantedBy = [ "${backend}-joplin.service" "${backend}-joplin-db.service" ];
    # script = ''
    #   mkdir -p ${joplin-data} && chown ${joplin-uid} ${joplin-data} || true
    #   mkdir -p ${joplin-db-data} || true
    #   ${config.virtualisation.podman.package}/bin/podman pod exists joplin ||
    #     ${config.virtualisation.podman.package}/bin/podman pod create -n joplin -p "127.0.0.1:22300:22300"
    # '';
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
  # systemd.services.podman-joplin = {
  #   # path = [ "/run/wrappers" ];
  #   # serviceConfig.User = config.mainuser;
  #   preStart = "podman network create -d bridge joplin || true";
  #   postStop = "podman network rm joplin || true";
  # };
  # systemd.services.podman-joplin-db = {
  #   # path = [ "/run/wrappers" ];
  #   # serviceConfig.User = config.mainuser;
  #   preStart = "podman network create -d bridge joplin || true";
  #   postStop = "podman network rm joplin || true";
  # };
  # systemd.services.create-joplin-folder = {
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [ "${backend}-joplin.service" ];
  #   script = ''
  #     mkdir -p ${joplin-data} && chown ${joplin-uid} ${joplin-data}
  #   '';
  # };
}