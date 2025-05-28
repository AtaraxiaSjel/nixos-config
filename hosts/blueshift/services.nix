{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  cert-key = config.sops.secrets."cert.key".path;
  cert-pem = config.sops.secrets."cert.pem".path;
  nginx-conf = config.sops.secrets."nginx.conf".path;
  marzban-env = config.sops.secrets.marzban.path;
  cfgOcis = config.services.ocis;
in
{
  # Tailscale exit-node
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Empty ocis in front
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.ocis.enable = true;
  services.ocis.url = "https://ro.ataraxiadev.com";
  services.ocis.configDir = "/var/lib/ocis/config";
  systemd.services.ocis.serviceConfig.ReadOnlyPaths = lib.mkForce [ ];
  systemd.services.ocis.serviceConfig.ExecStartPre = pkgs.writeShellScript "ocis-init" ''
    ${lib.getExe cfgOcis.package} init --force-overwrite --insecure true --config-path ${config.services.ocis.configDir}
  '';

  # Marzban
  sops.secrets =
    let
      nginx = {
        sopsFile = secretsDir + /blueshift/nginx.yaml;
        restartUnits = [ "podman-nginx.service" ];
      };
      marzban = {
        format = "dotenv";
        sopsFile = secretsDir + /blueshift/marzban.env;
        restartUnits = [ "podman-marzban.service" ];
      };
    in
    {
      "cert.key" = nginx;
      "cert.pem" = nginx;
      "nginx.conf" = nginx;
      inherit marzban;
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
        "${nginx-conf}:/etc/nginx/nginx.conf:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${cfgOcis.configDir} 0700 ${cfgOcis.user} ${cfgOcis.group} -"
    "d /srv/marzban 0755 root root -"
  ];
}
