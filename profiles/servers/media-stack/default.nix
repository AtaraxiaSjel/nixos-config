{ config, pkgs, ... }:
with config.virtualisation.oci-containers; {
  imports = [
    ./bazarr.nix
    ./botdarr.nix
    ./caddy.nix
    ./jellyfin.nix
    ./kavita.nix
    ./lidarr.nix
    ./nzbhydra2.nix
    ./organizr.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./shoko.nix
    ./sonarr.nix
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
      "${backend}-bazarr.service"
      "${backend}-botdarr-matrix.service"
      "${backend}-botdarr-telegram.service"
      "${backend}-jellyfin.service"
      "${backend}-kavita.service"
      "${backend}-lidarr.service"
      "${backend}-media-caddy.service"
      "${backend}-nzbhydra2.service"
      "${backend}-organizr.service"
      "${backend}-prowlarr.service"
      "${backend}-qbittorrent.service"
      "${backend}-radarr.service"
      "${backend}-shokoserver.service"
      "${backend}-sonarr-anime.service"
      "${backend}-sonarr-tv.service"
      "${backend}-xray.service"
    ];
    script = ''
      ${pkgs.docker}/bin/docker network inspect media || \
        ${pkgs.docker}/bin/docker network create -d bridge media
      exit 0
    '';
  };
}