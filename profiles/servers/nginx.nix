{ config, lib, pkgs, ... }: {
  security.acme = {
    acceptTerms = true;
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # staging
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory"; # production
    defaults.email = "ataraxiadev@ataraxiadev.com";
    defaults.renewInterval = "weekly";
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
          "jellyfin.ataraxiadev.com"
          "radarr.ataraxiadev.com"
          "qbit.ataraxiadev.com"
          "prowlarr.ataraxiadev.com"
          "sonarr.ataraxiadev.com"
          "sonarrtv.ataraxiadev.com"
          "organizr.ataraxiadev.com"
          "lidarr.ataraxiadev.com"
          "bazarr.ataraxiadev.com"
          "nzbhydra.ataraxiadev.com"
          "kavita.ataraxiadev.com"
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
    commonHttpConfig = ''
      proxy_hide_header X-Frame-Options;
      proxy_hide_header Content-Security-Policy;
      add_header X-XSS-Protection "1; mode=block";
      add_header Content-Security-Policy "frame-ancestors 'self' https://*.ataraxiadev.com moz-extension://43a2224f-fe82-45d7-bdc3-c218984e73c8";
      add_header X-Robots-Tag "none";
      add_header Referrer-Policy "strict-origin-when-cross-origin";
      add_header X-Content-Type-Options "nosniff";
    '';
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
          add_header Content-Security-Policy "frame-ancestors 'self' https://*.ataraxiadev.com";
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
        locations."/" = {
          extraConfig = "try_files $uri $uri/ =404;";
        };
        locations."/cgi-bin/" = with config.services; {
          extraConfig = ''
            gzip off;
            root /srv/http/ataraxiadev.com;
            fastcgi_pass ${fcgiwrap.socketType}:${fcgiwrap.socketAddress};
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
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
          # extraConfig = ''
          #   add_header X-XSS-Protection "1; mode=block";
          #   add_header X-Robots-Tag "none";
          #   add_header Referrer-Policy "strict-origin-when-cross-origin";
          #   add_header X-Content-Type-Options "nosniff";
          # '';
        };
      } // default;
      "vw.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:8812";
        } // proxySettings;
        locations."/notifications/hub" = {
          proxyPass = "http://localhost:3012";
          proxyWebsockets = true;
        } // proxySettings;
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://localhost:8812";
        } // proxySettings;
      } // default;
      "code.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:6000";
        } // proxySettings;
      } // default;
      "file.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://localhost:8088";
        } // proxySettings;
      } // default;
      "webmail.ataraxiadev.com" = {
        locations."/" = {
          extraConfig = ''
            client_max_body_size 30M;
          '';
        } // proxySettings;
      } // default;
      "media-stack" = {
        serverAliases = [
          "jellyfin.ataraxiadev.com"
          "radarr.ataraxiadev.com"
          "qbit.ataraxiadev.com"
          "prowlarr.ataraxiadev.com"
          "sonarr.ataraxiadev.com"
          "sonarrtv.ataraxiadev.com"
          "organizr.ataraxiadev.com"
          "lidarr.ataraxiadev.com"
          "bazarr.ataraxiadev.com"
          "nzbhydra.ataraxiadev.com"
          "kavita.ataraxiadev.com"
        ];
        locations."/" = {
          proxyPass = "http://localhost:8100";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            send_timeout 15m;
            proxy_connect_timeout 600;
            proxy_send_timeout 600;
            proxy_read_timeout 15m;
          '';
        };
      } // default;
    };
  };

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
    group = config.services.nginx.group;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}
