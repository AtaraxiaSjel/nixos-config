{ config, pkgs, lib, dns-mapping ? {}, ... }:
let
  domain = (import ../hardware/networks.nix).domain;
  bridgeName = (import ../hardware/networks.nix).interfaces.main'.bridgeName;
  tailscalePort = config.services.tailscale.port;
  tailscaleIfname = config.services.tailscale.interfaceName;
in {
  networking.firewall.interfaces.${bridgeName}.allowedUDPPorts = [ tailscalePort ];
  networking.firewall.trustedInterfaces = [ tailscaleIfname ];

  systemd.network.networks."50-tailscale" = {
    matchConfig.Name = tailscaleIfname;
    linkConfig.Unmanaged = true;
    linkConfig.ActivationPolicy = "manual";
  };
  environment.systemPackages = [ config.services.headscale.package ];

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8080;
    settings = {
      logtail.enabled = false;
      server_url = "https://${domain}";
      ip_prefixes = [
        "fd7a:115c:a1e0::/64" "100.64.0.0/16"
      ];
      dns_config = {
        base_domain = domain;
        nameservers = [ "127.0.0.1" ];
        extra_records = dns-mapping;
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
  systemd.services.headscale = {
    serviceConfig.TimeoutStopSec = 10;
    serviceConfig.EnvironmentFile = "/srv/headscale-oidc";
    serviceConfig.ExecStartPre = (pkgs.writeShellScript "wait-dns.sh" ''
      until ${pkgs.host}/bin/host auth.ataraxiadev.com > /dev/null; do sleep 1; done
    '');
  };

  services.tailscale = {
    enable = true;
    port = 18491;
    useRoutingFeatures = "both";
  };
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = false;
    useACMEHost = "wg.ataraxiadev.com";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}