{ config, inputs, ... }: {
  sops.secrets.authentik-env.sopsFile = inputs.self.secretsDir + /home-hypervisor/authentik.yaml;
  sops.secrets.authentik-ldap.sopsFile = inputs.self.secretsDir + /home-hypervisor/authentik.yaml;
  sops.secrets.authentik-env.restartUnits = [ "authentik-server.service" "authentik-worker.service" ];
  sops.secrets.authentik-ldap.restartUnits = [ "authentik-ldap-outpost.service" ];

  backups.postgresql.authentik = {};

  services.authentik = {
    enable = true;
    logLevel = "info";
    listen.address = "127.0.0.1";
    listen.http = 9000;
    listen.https = 9443;
    environmentFile = config.sops.secrets.authentik-env.path;
    outposts.ldap = {
      enable = true;
      host = "https://auth.ataraxiadev.com";
      environmentFile = config.sops.secrets.authentik-ldap.path;
      listen.address = "127.0.0.1";
      listen.ldap = 3389;
      listen.ldaps = 6636;
    };
  };

  # networking.firewall.allowedTCPPorts = [ 389 ];
}