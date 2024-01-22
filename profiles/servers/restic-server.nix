{ config, inputs, ... }:
let
  resticPort = 8010;
  fqdn = "restic.ataraxiadev.com";
  certFile = "${config.security.acme.certs.${fqdn}.directory}/fullchain.pem";
  keyFile = "${config.security.acme.certs.${fqdn}.directory}/key.pem";
in {
  sops.secrets.restic-htpasswd.sopsFile = inputs.self.secretsDir + /home-hypervisor/restic.yaml;
  sops.secrets.restic-htpasswd.restartUnits = [ "restic-rest-server.service" ];
  sops.secrets.restic-htpasswd.owner = "restic";

  security.acme.certs.${fqdn} = {
    webroot = "/var/lib/acme/acme-challenge";
    postRun = "systemctl reload restic-rest-server";
    group = "restic";
  };

  networking.firewall.allowedTCPPorts = [ resticPort ];
  networking.firewall.allowPing = true;
  services.restic.server = {
    enable = true;
    dataDir = "/media/nas/backups/restic";
    listenAddress = ":${toString resticPort}";
    # appendOnly = true;
    privateRepos = true;
    prometheus = true;
    extraFlags = [
      "--prometheus-no-auth"
      "--htpasswd-file=${config.sops.secrets.restic-htpasswd.path}"
      "--tls" "--tls-cert=${certFile}" "--tls-key=${keyFile}"
    ];
  };
}