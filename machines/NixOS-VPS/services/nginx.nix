{ config, pkgs, lib, ... }: {
  security.acme = {
    acceptTerms = true;
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    defaults.email = "admin@ataraxiadev.com";
    defaults.renewInterval = "weekly";
    certs = {
      "wg.ataraxiadev.com" = {
        webroot = "/var/lib/acme/acme-challenge";
        extraDomainNames = [
          "anime.ataraxiadev.com"
          "auth.ataraxiadev.com"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    group = "acme";
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    # recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
    appendConfig = ''
      worker_processes auto;
    '';
    appendHttpConfig = ''
      map $proxy_protocol_addr $proxy_forwarded_elem {
          ~^[0-9.]+$        "for=$proxy_protocol_addr";
          ~^[0-9A-Fa-f:.]+$ "for=\"[$proxy_protocol_addr]\"";
          default           "for=unknown";
      }
      map $http_forwarded $proxy_add_forwarded {
          "~^(,[ \\t]*)*([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?(;([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?)*([ \\t]*,([ \\t]*([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?(;([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?)*)?)*$" "$http_forwarded, $proxy_forwarded_elem";
          default "$proxy_forwarded_elem";
      }
      server {
        listen 80;
        listen [::]:80;
        return 301 https://$host$request_uri;
      }
    '';
    eventsConfig = ''
      worker_connections 1024;
    '';
    streamConfig = ''
      map $ssl_preread_server_name    $name {
          auth.ataraxiadev.com        auth_backend;
          wg.ataraxiadev.com          wg_backend;
          anime.ataraxiadev.com       anime_backend;
          default                     default_backend;
      }
      upstream auth_backend {
          server 127.0.0.1:8010;
      }
      upstream wg_backend {
          server 127.0.0.1:8011;
      }
      upstream anime_backend {
          server 127.0.0.1:8001;
      }
      upstream default_backend {
          server 127.0.0.1:8020;
      }
      server {
          listen 443        reuseport;
          listen [::]:443   reuseport;
          proxy_pass        $name;
          ssl_preread       on;
          proxy_protocol    on;
      }
    '';
    virtualHosts."reject" = {
      listen = [{
        addr = "127.0.0.1";
        port = 8020;
        ssl = true;
        extraParameters = [ "proxy_protocol" ];
      }];
      rejectSSL = true;
    };
  };
}