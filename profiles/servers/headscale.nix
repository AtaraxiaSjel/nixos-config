{ headscale-list ? {} }: { config, lib, inputs, ... }:
let
  domain = "wg.ataraxiadev.com";
in {
  environment.systemPackages = [ config.services.headscale.package ];

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8005;
    settings = {
      server_url = "https://${domain}";
      ip_prefixes = [
        "fd7a:115c:a1e0::/64" "100.64.0.0/16"
      ];
      dns_config = {
        override_local_dns = true;
        base_domain = domain;
        nameservers = [ "127.0.0.1" ];
        extra_records = headscale-list;
      };
      oidc = {
        only_start_if_oidc_is_available = true;
        issuer = "https://auth.ataraxiadev.com/application/o/headscale/";
        client_id = "n6UBhK8PahexLPb7GkU1xzoFLcYxQX0HWDytpUoi";
        client_secret_path = config.sops.secrets.headscale-oidc.path;
        scope = [ "openid" "profile" "email" "groups" ];
        allowed_groups = [ "headscale" ];
        strip_email_domain = true;
      };
      grpc_listen_addr = "127.0.0.1:50443";
      grpc_allow_insecure = true;
      disable_check_updates = true;
      ephemeral_node_inactivity_timeout = "4h";
    };
  };

  sops.secrets.headscale-oidc = {
    sopsFile = inputs.self.secretsDir + /home-hypervisor/headscale.yaml;
    owner = "headscale";
    restartUnits = [ "headscale.service" ];
  };
  systemd.services.headscale = {
    serviceConfig.TimeoutStopSec = 10;
      after = lib.mkIf config.services.authentik.enable [
      "authentik-server.service"
      "authentik-worker.service"
      "nginx.service"
    ];
  };

  persist.state.directories = [ "/var/lib/headscale" ];
}