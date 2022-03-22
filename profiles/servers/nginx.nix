{ config, lib, pkgs, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "ataraxiadev@ataraxiadev.com";
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
          "startpage.ataraxiadev.com"
          "vw.ataraxiadev.com"
          "code.ataraxiadev.com"
          "file.ataraxiadev.com"
          "webmail.ataraxiadev.com"
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
    clientMaxBodySize = "250m";
    virtualHosts = let
      default = {
        useACMEHost = "ataraxiadev.com";
        enableACME = false;
        forceSSL = true;
      };
      proxySettings = {
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
        '';
      };
      hardened = {
        extraConfig = ''
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-Robots-Tag "none";
          add_header Referrer-Policy "strict-origin-when-cross-origin";
          add_header X-Content-Type-Options "nosniff";
        '';
      };
    in {
      "ataraxiadev.com" = {
        locations."/.well-known/matrix" = {
          proxyPass = "https://matrix.ataraxiadev.com/.well-known/matrix";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
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
          proxyPass = "http://matrix.pve:81";
        } // proxySettings;
      } // default;
      "matrix:8448" = {
        serverAliases = [ "matrix.ataraxiadev.com" ];
        listen = [{
          addr = "0.0.0.0";
          port = 8448;
          ssl = true;
        }];
        locations."/" = {
          proxyPass = "http://matrix.pve:8449";
        } // proxySettings;
      } // default;
      "startpage.ataraxiadev.com" = {
        locations."/" = {
          root = "/srv/http/startpage.ataraxiadev.com/";
          extraConfig = ''
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag "none";
            add_header Referrer-Policy "strict-origin-when-cross-origin";
            add_header X-Content-Type-Options "nosniff";
          '';
        };
      } // default;
      "vw.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:8812";
        } // proxySettings // hardened;
        locations."/notifications/hub" = {
          proxyPass = "http://localhost:3012";
          proxyWebsockets = true;
        } // proxySettings // hardened;
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://localhost:8812";
        } // proxySettings // hardened;
      } // default;
      "code.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:6000";
        } // proxySettings // hardened;
      } // default;
      "file.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:8088/";
        } // proxySettings // hardened;
      } // default;
      "webmail.ataraxiadev.com" = {
        locations."/" = {
          extraConfig = ''
            client_max_body_size 30M;
          '';
        } // hardened;
      } // default;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}