{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.nzbhydra2 = {
    autoStart = true;
    environment = {
      PUID = "1020";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/nzbhydra2:release-4.3.0";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/nzbhydra2/config:/config"
      # "/media/data:/data"
    ];
  };
}