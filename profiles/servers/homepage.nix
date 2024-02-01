{ config, inputs, ... }: {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.homepage ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = 3000;
    dataDir = "/srv/homepage";
  };

  systemd.tmpfiles.rules = let
    cfg = config.services.homepage-dashboard;
  in [
    "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
  ];

  virtualisation.oci-containers.containers.docker-proxy = {
    autoStart = true;
    image = "ghcr.io/tecnativa/docker-socket-proxy:0.1.1";
    environment = {
      CONTAINERS = "1";
      SERVICES = "0";
      TASKS = "0";
      POST = "0";
    };
    ports = [ "127.0.0.1:2375:2375/tcp" ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
  };
}