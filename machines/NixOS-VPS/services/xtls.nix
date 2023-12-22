{ config, pkgs, lib, inputs, ... }:
let
  cert-key = config.sops.secrets."cert.key".path;
  cert-pem = config.sops.secrets."cert.pem".path;
  nginx-conf = config.sops.secrets."nginx.conf".path;
  marzban-env = config.sops.secrets.marzban.path;
in {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  sops.secrets = let
    nginx = {
      sopsFile = inputs.self.secretsDir + /nixos-vps/nginx.yaml;
      restartUnits = [ "podman-nginx.service" ];
    };
    marzban = {
      format = "dotenv";
      sopsFile = inputs.self.secretsDir + /nixos-vps/marzban.env;
      restartUnits = [ "podman-marzban.service" ];
    };
  in {
    "cert.key" = nginx;
    "cert.pem" = nginx;
    "nginx.conf" = nginx;
    marzban = marzban;
  };

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
    marzban = {
      autoStart = true;
      image = "ghcr.io/gozargah/marzban:v0.4.1";
      environmentFiles = [ marzban-env ];
      extraOptions = [ "--network=host" ];
      volumes = [
        "/srv/marzban:/var/lib/marzban"
      ];
    };
    nginx = {
      autoStart = true;
      image = "docker.io/nginx:latest";
      extraOptions = [ "--network=host" ];
      volumes = [
        "${cert-key}:/etc/ssl/certs/cert.key:ro"
        "${cert-pem}:/etc/ssl/certs/cert.pem:ro"
        "${nginx-conf}:/etc/nginx/nginx.conf:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/marzban 0755 root root -"
    "d /srv/nextcloud/html 0755 33 33 -"
    "d /srv/nextcloud/config 0755 33 33 -"
    "d /srv/nextcloud/data 0755 33 33 -"
  ];
}