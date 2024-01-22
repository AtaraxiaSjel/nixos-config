{ config, pkgs, inputs, headscale-list ? {}, ... }:
let
  domain = "wg.ataraxiadev.com";
in {
  environment.systemPackages = [ config.services.headscale.package ];

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8005;
    settings = {
      logtail.enabled = false;
      server_url = "https://${domain}";
      ip_prefixes = [
        "fd7a:115c:a1e0::/64" "100.64.0.0/16"
      ];
      dns_config = {
        base_domain = domain;
        nameservers = [ "127.0.0.1" ];
        extra_records = headscale-list;
      };
      oidc = {
        only_start_if_oidc_is_available = true;
        issuer = "https://auth.ataraxiadev.com/application/o/headscale/";
        client_id = "n6UBhK8PahexLPb7GkU1xzoFLcYxQX0HWDytpUoi";
        scope = [ "openid" "profile" "email" "groups" ];
        allowed_groups = [ "headscale" ];
        strip_email_domain = true;
      };
    };
  };

  sops.secrets.headscale-oidc = {
    sopsFile = inputs.self.secretsDir + /home-hypervisor/headscale.yaml;
    owner = "headscale";
    restartUnits = [ "headscale.service" ];
  };
  systemd.services.headscale = {
    serviceConfig.TimeoutStopSec = 10;
    serviceConfig.TimeoutStartSec = 300;
    serviceConfig.EnvironmentFile = config.sops.secrets.headscale-oidc.path;
    serviceConfig.ExecStartPre = (pkgs.writeShellScript "wait-dns.sh" ''
      until ${pkgs.host}/bin/host auth.ataraxiadev.com > /dev/null; do sleep 1; done
    '');
  };

  persist.state.directories = [ "/var/lib/headscale" ];
}