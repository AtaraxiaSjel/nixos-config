{ config, pkgs, lib, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  virtualisation.oci-containers.containers = {
    nextcloud = {
      autoStart = true;
      image = "docker.io/nextcloud:stable";
      ports = [ "9765:80" ];
      volumes = [
        "/srv/nextcloud/html:/var/www/html"
        "/srv/nextcloud/config:/var/www/html/config"
        "/srv/nextcloud/data:/var/www/html/data"
      ];
    };
    x-ui = {
      autoStart = true;
      image = "ghcr.io/mhsanaei/3x-ui:v1.7.8";
      environment = {
        XRAY_VMESS_AEAD_FORCED = "false";
      };
      extraOptions = [ "--network=host" ];
      volumes = [
        "/srv/x-ui/db:/etc/x-ui"
        "/srv/x-ui/certs:/root/cert"
      ];
    };
    nginx = {
      autoStart = true;
      image = "docker.io/nginx:latest";
      extraOptions = [ "--network=host" ];
      volumes = [
        "/srv/nginx/certs:/etc/ssl/certs:ro"
        "/srv/nginx/nginx.conf:/etc/nginx/nginx.conf:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/x-ui/db 0755 root root -"
    "d /srv/x-ui/certs 0755 root root -"
    "d /srv/nextcloud/html 0755 33 33 -"
    "d /srv/nextcloud/config 0755 33 33 -"
    "d /srv/nextcloud/data 0755 33 33 -"
  ];
}