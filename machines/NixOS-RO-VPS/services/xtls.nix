{ config, pkgs, inputs, modulesPath, ... }:
let
  inherit (pkgs.hostPlatform) system;
  cert-key = config.sops.secrets."cert.key".path;
  cert-pem = config.sops.secrets."cert.pem".path;
  nginx-conf = config.sops.secrets."nginx.conf".path;
  marzban-env = config.sops.secrets.marzban.path;
  fqdn = "wg.ataraxiadev.com";
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
    cf-dns-api = {
      sopsFile = inputs.self.secretsDir + /misc.yaml;
      owner = "acme";
    };
  in {
    "cert.key" = nginx;
    "cert.pem" = nginx;
    "nginx.conf" = nginx;
    inherit cf-dns-api marzban;
  };

  virtualisation.oci-containers.containers = {
    marzban = {
      autoStart = true;
      # Tags: v0.8.4
      image = "ghcr.io/gozargah/marzban@sha256:8e422c21997e5d2e3fa231eeff73c0a19193c20fc02fa4958e9368abb9623b8d";
      environmentFiles = [ marzban-env ];
      extraOptions = [ "--network=host" ];
      volumes = [
        "/srv/marzban:/var/lib/marzban"
      ];
    };
    nginx = {
      autoStart = true;
      # Tags: mainline-alpine3.21, mainline-alpine, alpine3.21
      image = "docker.io/nginx@sha256:e4efffc3236305ae53fb54e5cd76c9ccac0cebf7a23d436a8f91bce6402c2665";
      extraOptions = [ "--network=host" ];
      volumes = [
        "${cert-key}:/etc/ssl/certs/cf-cert.key:ro"
        "${cert-pem}:/etc/ssl/certs/cf-cert.pem:ro"
        "${config.security.acme.certs.${fqdn}.directory}/fullchain.pem:/etc/ssl/certs/cert.pem:ro"
        "${config.security.acme.certs.${fqdn}.directory}/key.pem:/etc/ssl/certs/cert.key:ro"
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

  # OpenConnect
  security.acme = {
    acceptTerms = true;
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory"; # production
    defaults.email = "admin@ataraxiadev.com";
    defaults.renewInterval = "weekly";
    certs = {
      ${fqdn} = {
        extraDomainNames = [
          "auth.ataraxiadev.com"
          "doh.ataraxiadev.com"
          "video.ataraxiadev.com"
        ];
        dnsResolver = "1.1.1.1:53";
        dnsProvider = "cloudflare";
        credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cf-dns-api.path;
        reloadServices = [ "podman-nginx.service" ];
      };
    };
  };
  persist.state.directories = [ "/var/lib/acme" ];
  environment.systemPackages = [ pkgs.ocserv ];

  networking.nat = let
    inherit (import ../hardware/networks.nix) interfaces;
  in {
    enable = true;
    externalInterface = interfaces.main'.ifname;
    internalInterfaces = [ "vpns0" ];
  };
  networking.firewall.trustedInterfaces = [ "vpns0" ];
  # networking.firewall.extraCommands = ''
  #   ${pkgs.iptables}/bin/iptables -t nat  -A POSTROUTING -s 10.90.0.0/24 -o enp0s18 -j SNAT --to-source 45.135.180.193
  # '';
}