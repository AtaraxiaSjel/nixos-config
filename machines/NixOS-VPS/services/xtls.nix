{ config, pkgs, inputs, modulesPath, ... }:
let
  inherit (pkgs.hostPlatform) system;
  cert-key = config.sops.secrets."cert.key".path;
  cert-pem = config.sops.secrets."cert.pem".path;
  nginx-conf = config.sops.secrets."nginx.conf".path;
  marzban-env = config.sops.secrets.marzban.path;
in {
  disabledModules = [ "${modulesPath}/services/web-apps/ocis.nix" ];
  imports = [ inputs.ataraxiasjel-nur.nixosModules.ocis ];
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
    marzban = {
      autoStart = true;
      image = "ghcr.io/gozargah/marzban:v0.4.9";
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

  services.ocis = {
    enable = true;
    package = inputs.ataraxiasjel-nur.packages.${system}.ocis-bin;
    configDir = "/srv/ocis/config";
    baseDataPath = "/srv/ocis/data";
    environment = {
      OCIS_INSECURE = "false";
      OCIS_URL = "https://cloud.ataraxiadev.com";
      PROXY_HTTP_ADDR = "127.0.0.1:9200";
      PROXY_TLS = "false";
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/marzban 0755 root root -"
  ];
}