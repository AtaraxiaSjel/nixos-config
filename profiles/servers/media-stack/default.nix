{ config, pkgs, ... }:
with config.virtualisation.oci-containers; {
  imports = [
    ./caddy.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./jellyfin.nix
    ./radarr.nix
    ./lidarr.nix
    ./sonarr.nix
    ./organizr.nix
    ./bazarr.nix
  ];

  secrets.xray-config = {
    services = [ "${backend}-xray.service" ];
  };

  virtualisation.oci-containers.containers.xray = {
    autoStart = true;
    environment = {
      TZ = "Europe/Moscow";
    };
    extraOptions = [
      "--network=media"
    ];
    image = "teddysun/xray:1.5.4";
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${config.secrets.xray-config.decrypted}:/etc/xray/config.json"
    ];
  };

  systemd.services.create-media-network = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-jellyfin.service"
      "${backend}-radarr.service"
      "${backend}-media-caddy.service"
      "${backend}-qbittorrent.service"
      "${backend}-prowlarr.service"
      "${backend}-xray.service"
      "${backend}-sonarr-tv.service"
      "${backend}-sonarr-anime.service"
      "${backend}-organizr.service"
      "${backend}-lidarr.service"
      "${backend}-bazarr.service"
    ];
    script = ''
      ${pkgs.docker}/bin/docker network inspect media || \
        ${pkgs.docker}/bin/docker network create -d bridge media
      exit 0
    '';
  };
}