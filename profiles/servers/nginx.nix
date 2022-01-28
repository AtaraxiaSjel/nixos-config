{ pkgs, config, lib, ... }: {
  users.groups.cert.members = [ "turnserver" "nginx" "dovecot2" ];

  secrets."ataraxiadev.com.pem" = {
    owner = "root:cert";
    permissions = "440";
  };
  secrets."ataraxiadev.com.key" = {
    owner = "root:cert";
    permissions = "440";
  };
  secrets."origin-pull-ca.pem" = {
    owner = "root:cert";
    permissions = "440";
  };
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
        locations."/.well-known/acme-challenge" = {
          root = "/var/lib/acme/acme-challenge";
        };
        locations."/.well-known/matrix/server".extraConfig =
          let
            server = { "m.server" = "matrix.ataraxiadev.com:443"; };
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."/.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://matrix.ataraxiadev.com"; };
              "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
        locations."/_matrix" = {
          proxyPass = "http://localhost:13748";
        };
      } // default;
      "matrix.ataraxiadev.com" = {
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/mautrix-telegram/" = {
          proxyPass = "http://localhost:29317";
        };
        locations."/_matrix" = {
          proxyPass = "http://localhost:13748";
        };
      } // default;
      "code.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:6000";
        };
      } // default;
    };
  };
}