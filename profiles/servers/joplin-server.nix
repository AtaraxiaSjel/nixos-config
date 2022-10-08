{ config, lib, pkgs, ... }: {
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
      image = "joplin:latest-dev";
      volumes = [ "/srv/joplin/data:/data" ];
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
  systemd.services.create-joplin-network = with config.virtualisation.oci-containers; {
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
}