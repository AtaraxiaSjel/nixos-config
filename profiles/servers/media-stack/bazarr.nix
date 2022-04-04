{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.bazarr = {
    autoStart = true;
    environment = {
      PUID = "1015";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "cr.hotio.dev/hotio/bazarr:release-1.0.3";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/bazarr/config:/config"
      "/media/data:/data"
    ];
  };
}