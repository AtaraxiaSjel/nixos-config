{ pkgs, config, lib, ... }: {
  secrets."ataraxiadev.com.pem" = {
    owner = "nginx:nginx";
  };
  secrets."ataraxiadev.com.key" = {
    owner = "nginx:nginx";
  };
  secrets."origin-pull-ca.pem" = {
    owner = "nginx:nginx";
  };
  ## DNS-over-TLS
  services.stubby = {
    enable = true;
    listenAddresses = [ "0::1" "127.0.0.1" ];
    roundRobinUpstreams = false;
    upstreamServers = ''
      ## Quad9
      - address_data: 2620:fe::fe
        tls_auth_name: "dns.quad9.net"
      - address_data: 2620:fe::9
        tls_auth_name: "dns.quad9.net"
      - address_data: 9.9.9.9
        tls_auth_name: "dns.quad9.net"
      - address_data: 149.112.112.112
        tls_auth_name: "dns.quad9.net"
      ## Cloudflare
      - address_data: 2606:4700:4700::1112
        tls_auth_name: "cloudflare-dns.com"
      - address_data: 2606:4700:4700::1002
        tls_auth_name: "cloudflare-dns.com"
      - address_data: 1.1.1.2
        tls_auth_name: "cloudflare-dns.com"
      - address_data: 1.0.0.2
        tls_auth_name: "cloudflare-dns.com"
    '';
    extraConfig = ''
      # Set TLS 1.3 as minimum acceptable version
      tls_min_version: GETDNS_TLS1_3
      # Require DNSSEC validation
      dnssec: GETDNS_EXTENSION_TRUE
    '';
  };

  networking.nameservers = [ "::1" "127.0.0.1" ];
  services.resolved = {
    enable = true;
    fallbackDns = [ "2606:4700:4700::1111" "2606:4700:4700::1001" "1.1.1.1" "1.0.0.1" ];
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    appendHttpConfig = "charset utf-8;";
    virtualHosts = let
      default = {
        forceSSL = true;
        enableACME = false;
        sslCertificate = config.secrets."ataraxiadev.com.pem".decrypted;
        sslCertificateKey = config.secrets."ataraxiadev.com.key".decrypted;
        sslTrustedCertificate = config.secrets."origin-pull-ca.pem".decrypted;
      };
    in {
      "ataraxiadev.com" = {
        default = true;
        locations."/" = {
          root = "/var/lib/ataraxiadev.com";
        };
        locations."/.well-known" = {
          proxyPass = "http://localhost:13748";
        };
        locations."/_matrix" = {
          proxyPass = "http://localhost:13748";
        };
      } // default;
      "matrix.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:13748";
        };
      } // default;
    };
  };
}