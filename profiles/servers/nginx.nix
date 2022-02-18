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
          "startpage.ataraxiadev.com"
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
      "startpage.ataraxiadev.com" = {
        locations."/" = {
          root = "/srv/http/startpage.ataraxiadev.com/";
        };
      } // default;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}