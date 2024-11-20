{ ... }:
{
  services.nginx = {
    enable = true;
    group = "acme";
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
    clientMaxBodySize = "250m";
    commonHttpConfig = ''
      proxy_hide_header X-Frame-Options;
    '';
    virtualHosts = let
      default = {
        useACMEHost = "ataraxiadev.com";
        enableACME = false;
        forceSSL = true;
      };
      proxySettings = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
      '';
    in {
      "media-stack" = {
        serverAliases = [
          "jellyfin.ataraxiadev.com"
          "qbit.ataraxiadev.com"
          "prowlarr.ataraxiadev.com"
          "jackett.ataraxiadev.com"
          "sonarr.ataraxiadev.com"
          "radarr.ataraxiadev.com"
          "lidarr.ataraxiadev.com"
          "kavita.ataraxiadev.com"
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8180";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            send_timeout 15m;
            proxy_connect_timeout 600;
            proxy_send_timeout 600;
            proxy_read_timeout 15m;
          '' + proxySettings;
        };
      } // default;
      "medusa.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8180";
          proxyWebsockets = true;
          extraConfig = ''
            add_header Content-Security-Policy "upgrade-insecure-requests";
          '' + proxySettings;
        };
      } // default;
      "ataraxiadev.com" = {
        extraConfig = ''
          return 301 https://code.ataraxiadev.com$request_uri;
        '';
      } // default;
      "cal.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:5232";
          extraConfig = proxySettings;
        };
      } // default;
      "code.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:6000";
          extraConfig = proxySettings;
        };
      } // default;
      "vw.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8812";
          extraConfig = proxySettings;
        };
        locations."/notifications/hub" = {
          proxyPass = "http://127.0.0.1:3012";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://127.0.0.1:8812";
          extraConfig = proxySettings;
        };
      } // default;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
