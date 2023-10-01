{ config, pkgs, lib, ... }: {
  services.nginx.virtualHosts."anime.ataraxiadev.com" = {
    onlySSL = true;
      enableACME = false;
      useACMEHost = "wg.ataraxiadev.com";
      listen = [{
        addr = "127.0.0.1";
      port = 8002;
      ssl = true;
        extraParameters = [ "proxy_protocol" ];
    }];
    extraConfig = ''
      set_real_ip_from           127.0.0.1;
      real_ip_header             proxy_protocol;
      ssl_early_data             on;
      resolver                   127.0.0.1 valid=60s;
      resolver_timeout           2s;
    '';
      locations."/" = {
      proxyPass = "https://monster-siren.hypergryph.com";
        proxyWebsockets = true;
        extraConfig = ''
        sub_filter                            $proxy_host $host;
        sub_filter_once                       off;
        proxy_set_header Host                 $proxy_host;
        proxy_cache_bypass                    $http_upgrade;
        proxy_ssl_server_name                 on;
        proxy_set_header X-Real-IP            $proxy_protocol_addr;
        proxy_set_header Forwarded            $proxy_add_forwarded;
        proxy_set_header X-Forwarded-For      $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto    $scheme;
        proxy_set_header X-Forwarded-Host     $host;
        proxy_set_header X-Forwarded-Port     $server_port;
        proxy_connect_timeout                 60s;
        proxy_send_timeout                    60s;
        proxy_read_timeout                    60s;
        proxy_set_header Early-Data           $ssl_early_data;
        '';
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