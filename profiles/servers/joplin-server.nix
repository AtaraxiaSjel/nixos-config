{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    joplin = {
      autoStart = true;
      dependsOn = [ "joplin-db" ];
      environment = {
        DB_CLIENT = "pg";
        POSTGRES_DATABASE = "joplin";
        POSTGRES_USER = "test";
        POSTGRES_PASSWORD = "test";
        POSTGRES_PORT = "5432";
        POSTGRES_HOST = "joplin-db";
        APP_PORT = "22300";
        APP_BASE_URL = "joplin.ataraxiadev.com";
      };
      extraOptions = [
        "--network=joplin"
      ];
      ports = [ "127.0.0.1:22300:22300" ];
      image = "joplin:latest-dev";
    };
    joplin-db = {
      autoStart = true;
      environment = {
        POSTGRES_PASSWORD= "test";
        POSTGRES_USER = "test";
        POSTGRES_DB = "joplin";
      };
      extraOptions = [
        "--network=joplin"
      ];
      image = "postgres:13";
      # volumes = [ "/server/data/postgres:/var/lib/postgresql/data" ];
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