{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.kavita = {
    autoStart = true;
    image = "docker.io/jvmilazz0/kavita:0.8.2";
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    extraOptions = [ "--pod=media-stack" ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${nas-path}/configs/kavita:/kavita/config"
      "${nas-path}/media/manga:/manga/manga"
      "${nas-path}/media/books:/manga/books"
      "${nas-path}/media/comics:/manga/comics"
    ];
  };
}