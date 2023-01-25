{ config, lib, pkgs, ... }: {
  # secrets.headscale-db.owner = config.services.headscale.user;
  # FIXME: https://github.com/juanfont/headscale/blob/main/config-example.yaml
  services.headscale = {
    enable = true;
    serverUrl = "http://192.168.0.100:8080";
    address = "192.168.0.100";
    serverUrl = "http://tailscale.ataraxiadev.com:8080";
    # address = "0.0.0.0";
    port = 8080;
    dns = {
      magicDns = true;
      nameservers = "192.168.0.1";
      baseDomain = "ataraxiadev.com";
    };
    # database.passwordFile = config.secrets.headscale-db.decrypted;
    # database.path = "/var/lib/headscale/db.sqlite";
    # privateKeyFile = "/var/lib/headscale/private.key";
  };
  environment.systemPackages = [ config.services.headscale.package ];
  networking.firewall.allowedTCPPorts = [ config.services.headscale.port ];

  persist.state.directories = [ "/var/lib/headscale" ];
}