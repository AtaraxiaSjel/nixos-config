{ config, pkgs, lib, ... }: {
  services.nginx.virtualHosts = {
    "anime.ataraxiadev.com" = {
      forceSSL = true;
      enableACME = false;
      useACMEHost = "wg.ataraxiadev.com";
      locations."/" = {
        extraConfig = ''
          proxy_pass http://127.0.0.1:5443;
        '';
      };
    };
    "xtls:8001" = {
      enableACME = false;
      forceSSL = false;
      listen = [{
        addr = "127.0.0.1";
        port = 8001;
        ssl = false;
        extraParameters = [ "http2" "proxy_protocol" ];
      }];
      serverAliases = [ "anime.ataraxiadev.com" ];
      locations."/" = {
        extraConfig = ''
          sub_filter                         $proxy_host $host;
          sub_filter_once                    off;
          proxy_pass                         https://www.crunchyroll.com;
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