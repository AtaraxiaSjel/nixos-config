{ pkgs, config, ... }:
{
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
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
      "jellyfin.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8180";
          extraConfig = ''
            proxy_buffering off;
          '' + proxySettings;
        };
        locations."/socket" = {
          proxyPass = "http://127.0.0.1:8180";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
        extraConfig = ''
          client_max_body_size 50M;
        '';
      } // default;
      "ataraxiadev.com" = {
        locations."/" = {
          root = "/srv/http/ataraxiadev.com/docroot";
          extraConfig = ''
            try_files $uri $uri/ =404;
          '';
        };
        locations."/hooks" = {
          proxyPass = "http://127.0.0.1:9510/hooks";
        };
      } // default;
      "auth.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
      } // default;
      "wg.ataraxiadev.com" = {
        locations."/headscale." = {
          extraConfig = ''
            grpc_pass grpc://${config.services.headscale.settings.grpc_listen_addr};
          '';
          priority = 1;
        };
        locations."/metrics" = {
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          extraConfig = ''
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            deny all;
          '';
          priority = 2;
        };
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          proxyWebsockets = true;
          priority = 3;
        };
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
      "lib.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8072";
          proxyWebsockets = true;
        };
      } // default;
      "tools.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8070";
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
      "wiki.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8190";
        };
      } // default;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
}
