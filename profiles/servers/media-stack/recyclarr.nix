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
    # Tags: 7.4.1, 7.4, 7
    image = "ghcr.io/recyclarr/recyclarr@sha256:759540877f95453eca8a26c1a93593e783a7a824c324fbd57523deffb67f48e1";
    volumes = [
      "${nas-path}/configs/recyclarr:/config"
    ];
    user = "1000:100";
  };
}