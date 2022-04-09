{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.kavita = {
    autoStart = true;
    environment = {
      PUID = "1022";
      PGID = "1005";
      UMASK = "002";
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "kizaing/kavita:0.5.2";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/media/configs/kavita/config:/kavita/config"
      "/media/data/media/books:/books"
    ];
  };
}