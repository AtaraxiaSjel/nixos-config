{ config, pkgs, lib, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@ataraxiadev.com";
    defaults.renewInterval = "weekly";
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
    # recommendedZstdSettings = true; # forcing nginx rebuild
    sslProtocols = "TLSv1.3";
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
    '';
    eventsConfig = ''
      worker_connections 1024;
    '';
    virtualHosts."wg.ataraxiadev.com" = {
      enableACME = true;
      forceSSL = true;
      listen = [{
        addr = "127.0.0.1";
        port = 8001;
        ssl = true;
        extraParameters = [ "proxy_protocol" ];
      }];
      extraConfig = ''
        set_real_ip_from 127.0.0.1;
      '';
      locations."/" = {
        extraConfig = ''
          sub_filter                         $proxy_host $host;
          sub_filter_once                    off;
          proxy_pass                         https://www.lovelive-anime.jp;
          proxy_set_header Host              $proxy_host;
          proxy_cache_bypass                 $http_upgrade;
          proxy_ssl_server_name on;
          proxy_set_header X-Real-IP         $proxy_protocol_addr;
          proxy_set_header Forwarded         $proxy_add_forwarded;
          proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host  $host;
          proxy_set_header X-Forwarded-Port  $server_port;
          proxy_connect_timeout              60s;
          proxy_send_timeout                 60s;
          proxy_read_timeout                 60s;
          resolver 127.0.0.1;
        '';
        proxyWebsockets = true;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/xray 0755 root root -"
  ];

  services.xray.enable = true;
  services.xray.settingsFile = "/srv/xray/config.json";
  systemd.services.xray.serviceConfig = {
    Group = "acme";
    User = "xray";
    DynamicUser = lib.mkForce false;
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
    AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
  };

  users.users.xray = {
    isSystemUser = true;
    group = "acme";
  };
}