{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkAfter recursiveUpdate;
  inherit (config.ataraxia.lists) ports;
  nginx = config.ataraxia.services.nginx;
  fs = config.ataraxia.filesystems;
  fsCompression = fs.zfs.enable || fs.btrfs.enable;
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

        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
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

  networking.firewall.allowedTCPPorts = [
    853
    9443
  ];

  services.nginx = {
    commonHttpConfig = mkAfter ''
      set_real_ip_from 127.0.0.1/32;
      set_real_ip_from ::1/128;
      real_ip_header proxy_protocol;
      real_ip_recursive on;

      log_format lean '$remote_addr - $http_host "$request" $status $body_bytes_sent "$http_user_agent"';
      map "$http_user_agent:$request_uri" $no_noise {
        default 1;
        ~*Uptime-Kuma 0;
        ~*:/(healthz|health|alive|api/healthz)([?/]|$) 0;
      }
      access_log /var/log/nginx/access.log lean buffer=64k flush=5m if=$no_noise;
    '';
    defaultListen = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
        proxyProtocol = true;
      }
      {
        addr = "[::0]";
        port = 80;
        ssl = false;
      }
      {
        addr = "[::0]";
        port = 443;
        ssl = true;
        proxyProtocol = true;
      }
    ];
    streamConfig = ''
      map $ssl_preread_server_name $home_split {
          home.ataraxiadev.com  home_in;
          default               127.0.0.1:443;
      }
      upstream home_in {
          server 127.0.0.1:10443; # Xray
          server 127.0.0.1:443 backup;
      }
      server {
          listen 9443 proxy_protocol;
          listen [::]:9443 proxy_protocol;
          set_real_ip_from 10.10.10.8/32;
          set_real_ip_from 127.0.0.1/32;
          set_real_ip_from ::1/128;
          ssl_preread on;
          proxy_pass $home_split;
          proxy_protocol on;
          proxy_timeout 2h;
          proxy_next_upstream on;
      }
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
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
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
      "home.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
        root = pkgs.writeTextDir "index.html" ''
          <!doctype html>
          <html lang="en">
          <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>home.ataraxiadev.com</title>
          <style>body{font-family:system-ui,sans-serif;max-width:42rem;margin:4rem auto;padding:0 1rem;color:#222}h1{font-size:1.4rem}a{color:#06c}</style>
          </head>
          <body>
          <h1>home server</h1>
          <p>personal box. nothing public here.</p>
          <ul>
          <li><a href="https://books.ataraxiadev.com/">books</a></li>
          <li><a href="https://wiki.ataraxiadev.com/">wiki</a></li>
          <li><a href="https://git.ataraxiadev.com/">git</a></li>
          </ul>
          </body>
          </html>
        '';
        locations."/".tryFiles = "$uri $uri/ =404";
      };
    };
  };

  services.logrotate = {
    enable = true;
    settings = {
      nginx = {
        compress = !fsCompression;
        enable = true;
        rotate = 5;
      };
    };
  };
}
