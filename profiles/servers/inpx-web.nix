{ ... }: let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.inpx-web = {
    autoStart = true;
    image = "docker.io/ataraxiadev/inpx-web:latest";
    ports = [ "127.0.0.1:8072:12380/tcp" ];
    user = "1000:100";
    volumes = [
      "${nas-path}/media/other/flibusta:/library:ro"
      "${nas-path}/configs/inpx-web:/app/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${nas-path}/configs/inpx-web 0755 1000 100 -"
  ];
}