{ ... }:
let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.recyclarr = {
    autoStart = true;
    environment = {
      CRON_SCHEDULE = "@daily";
      TZ = "Europe/Moscow";
    };
    extraOptions = [ "--pod=media-stack" ];
    image = "ghcr.io/recyclarr/recyclarr:5.4.3";
    volumes = [
      "${nas-path}/configs/recyclarr:/config"
    ];
    user = "1000:100";
  };
}