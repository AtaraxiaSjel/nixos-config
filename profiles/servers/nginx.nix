{ config, lib, pkgs, ... }: {
  security.acme = {
    acceptTerms = true;
    email = "ataraxiadev@ataraxiadev.com";
    certs = {
      "ataraxiadev.com" = {
        webroot = "/var/lib/acme/acme-challenge";
        extraDomainNames = [
          "matrix.ataraxiadev.com"
          "cinny.ataraxiadev.com"
          "dimension.ataraxiadev.com"
          "element.ataraxiadev.com"
          "goneb.ataraxiadev.com"
          "jitsi.ataraxiadev.com"
          "stats.ataraxiadev.com"
        ];
      };
    };
  };

  services.nginx = {
    enable = true;
    group = "acme";
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    virtualHosts = let
      default = {
        useACMEHost = "ataraxiadev.com";
        forceSSL = true;
      };
      proxyPass = {
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Host $host;
        '';
      };
    in {
      "ataraxiadev.com" = {
        locations."/.well-known/matrix" = {
          proxyPass = "https://matrix.ataraxiadev.com/.well-known/matrix";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            # proxy_set_header Access-Control-Allow-Origin *;
            # if ($request_method = 'POST') {
            #   add_header 'Access-Control-Allow-Origin' '*';
            #   add_header 'Access-Control-Allow-Credentials' 'true';
            #   add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            #   add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
            # }
            # if ($request_method = 'GET') {
            #   add_header 'Access-Control-Allow-Origin' '*';
            #   add_header 'Access-Control-Allow-Credentials' 'true';
            #   add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            #   add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
            # }
            # if ($request_method = 'OPTIONS') {
            #   add_header 'Access-Control-Allow-Origin' '*';
            #   add_header 'Access-Control-Allow-Credentials' 'true';
            #   add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            #   add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
            # }
          '';
        };
      } // default;
      "matrix:443" = {
        serverAliases = [
          "matrix.ataraxiadev.com"
          "cinny.ataraxiadev.com"
          "dimension.ataraxiadev.com"
          "element.ataraxiadev.com"
          "goneb.ataraxiadev.com"
          "jitsi.ataraxiadev.com"
          "stats.ataraxiadev.com"
        ];
        listen = [{
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }];
        locations."/" = {
          proxyPass = "http://matrix-ct:81";
        } // proxyPass;
      } // default;
      "matrix:8448" = {
        serverAliases = [ "matrix.ataraxiadev.com" ];
        listen = [{
          addr = "0.0.0.0";
          port = 8448;
          ssl = true;
        }];
        locations."/" = {
          proxyPass = "http://matrix-ct:8449";
        } // proxyPass;
      } // default;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}