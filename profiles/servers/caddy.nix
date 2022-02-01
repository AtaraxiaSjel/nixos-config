{ config, lib, pkgs, ...}: {
  services.caddy = {
    enable = true;
    # acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
    globalConfig = ''
      email ataraxiadev@ataraxiadev.com
    '';
    virtualHosts = let
      # default = {
      #   useACMEHost = "ataraxiadev.com";
      # };
    in {
      "ataraxiadev.com" = {
        serverAliases = [ "www.ataraxiadev.com" ];
        # listenAddresses = [ "0.0.0.0" ];
        extraConfig = ''
          templates
          encode gzip zstd
          root * /srv/www/ataraxiadev.com
          file_server
        '';
      };
      "matrix.ataraxiadev.com" = {
        extraConfig = ''
          @identity {
            path /_matrix/identity/*
          }
          @noidentity {
            not path /_matrix/identity/*
          }
          @search {
            path /_matrix/client/r0/user_directory/search/*
          }
          @nosearch {
            not path /_matrix/client/r0/user_directory/search/*
          }
          @static {
            path /matrix/static-files/*
          }
          @nostatic {
            not path /matrix/static-files/*
          }
          @wellknown {
            path /.well-known/matrix/*
          }
          header {
            # Enable HTTP Strict Transport Security (HSTS) to force clients to always connect via HTTPS
            # Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            # Enable cross-site filter (XSS) and tell browser to block detected attacks
            X-XSS-Protection "1; mode=block"
            # Prevent some browsers from MIME-sniffing a response away from the declared Content-Type
            X-Content-Type-Options "nosniff"
            # Disallow the site to be rendered within a frame (clickjacking protection)
            X-Frame-Options "DENY"
            # X-Robots-Tag
            X-Robots-Tag "noindex, noarchive, nofollow"
          }
          # Cache
          header @static {
            # Cache
            Cache-Control "public, max-age=31536000"
            defer
          }
          # identity
          handle @identity {
            reverse_proxy localhost:8090  {
              header_up X-Forwarded-Port {http.request.port}
              header_up X-Forwarded-Proto {http.request.scheme}
              header_up X-Forwarded-TlsProto {tls_protocol}
              header_up X-Forwarded-TlsCipher {tls_cipher}
              header_up X-Forwarded-HttpsProto {proto}
            }
          }
          # search
          handle @search {
            reverse_proxy localhost:8090   {
              header_up X-Forwarded-Port {http.request.port}
              header_up X-Forwarded-Proto {http.request.scheme}
              header_up X-Forwarded-TlsProto {tls_protocol}
              header_up X-Forwarded-TlsCipher {tls_cipher}
              header_up X-Forwarded-HttpsProto {proto}
            }
          }
          handle @wellknown {
            encode zstd gzip
            root * /matrix/static-files
            header Cache-Control max-age=14400
            header Content-Type application/json
            header Access-Control-Allow-Origin *
            file_server
          }
          handle {
            encode zstd gzip
            reverse_proxy localhost:8008  {
              header_up X-Forwarded-Port {http.request.port}
              header_up X-Forwarded-Proto {http.request.scheme}
              header_up X-Forwarded-TlsProto {tls_protocol}
              header_up X-Forwarded-TlsCipher {tls_cipher}
              header_up X-Forwarded-HttpsProto {proto}
            }
          }
        '';
      };
    };
  };

  users.users.caddy.extraGroups = [ "acme" ];
}