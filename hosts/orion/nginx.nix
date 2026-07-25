{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) recursiveUpdate;
  inherit (config.ataraxia.lists) ports;
  nginx = config.ataraxia.services.nginx;
in
{
  ataraxia.services.nginx.enable = true;
  ataraxia.services.nginx.defaultSettings = {
    useACMEHost = "ataraxiadev.com";
    enableACME = false;
    forceSSL = true;
  };
  ataraxia.services.nginx.tinyauthSettings = recursiveUpdate nginx.defaultSettings {
    # TODO: Fix "/" location recursiveUpdate. Maybe rewrite recursiveUpdateUntil to concat types.lines?
    locations."/".extraConfig = ''
      # Tinyauth auth request
      auth_request /tinyauth;
      auth_request_set $redirection_url $upstream_http_x_tinyauth_location;
      error_page 401 403 =302 $redirection_url;
    '';
    locations."/tinyauth" = {
      proxyPass = "http://127.0.0.1:${ports.tinyauth.str}/api/auth/nginx";
      extraConfig = ''
        internal;
        # Pass the request headers
        proxy_set_header x-forwarded-proto $scheme;
        proxy_set_header x-forwarded-host $http_host;
        proxy_set_header x-forwarded-uri $request_uri;
      '';
      recommendedProxySettings = false;
    };
  };

  sops.secrets = {
    incus-crt = {
      sopsFile = secretsDir + /${config.networking.hostName}/incus.yaml;
      reloadUnits = [ "nginx.service" ];
      owner = "nginx";
    };
    incus-key = {
      sopsFile = secretsDir + /${config.networking.hostName}/incus.yaml;
      reloadUnits = [ "nginx.service" ];
      owner = "nginx";
    };
  };

  networking.firewall.allowedTCPPorts = [ 853 ];
  services.nginx = {
    streamConfig = ''
      server {
        # Proxy dns-over-tls traffic to local dns server
        listen 853;
        proxy_pass 10.10.10.9:853;
      }
    '';
    virtualHosts = {
      "dns.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://10.10.10.9:5380";
          proxyWebsockets = true;
          extraConfig = ''
            allow 127.0.0.1/32;
            allow 10.10.10.0/24;
            deny all;
          '';
        };
        locations."= /dns-query" = {
          proxyPass = "http://10.10.10.9:80";
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
          '';
        };
      };
      "incus.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "https://10.10.10.5:8443";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_certificate ${config.sops.secrets.incus-crt.path};
            proxy_ssl_certificate_key ${config.sops.secrets.incus-key.path};
            proxy_ssl_server_name on;

            auth_request /tinyauth;
            auth_request_set $redirection_url $upstream_http_x_tinyauth_location;
            error_page 401 403 =302 $redirection_url;
          '';
        };
      };
    };
  };
}
