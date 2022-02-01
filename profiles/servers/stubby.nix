{ config, lib, pkgs, ... }: {
  ## DNS-over-TLS
  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      dnssec = "GETDNS_EXTENSION_TRUE";
      listen_addresses = [ "0::1" "127.0.0.1" ];
      resolution_type = "GETDNS_RESOLUTION_STUB";
      round_robin_upstreams = 1;
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      tls_min_version = "GETDNS_TLS1_3";
      upstream_recursive_servers = [
        {
          address_data = "2620:fe::fe";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "2620:fe::9";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "9.9.9.9";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "149.112.112.112";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "2606:4700:4700::1112";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "2606:4700:4700::1002";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "1.1.1.2";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "1.0.0.2";
          tls_auth_name = "cloudflare-dns.com";
        }
      ];
    };
  };

  networking.nameservers = [ "::1" "127.0.0.1" ];
  services.resolved = {
    enable = true;
    fallbackDns = [ "2606:4700:4700::1111" "2606:4700:4700::1001" "1.1.1.1" "1.0.0.1" ];
  };
}