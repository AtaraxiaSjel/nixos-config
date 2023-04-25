{ config, lib, pkgs, ... }:
let
  authentik = { root ? {}, rootExtraConfig ? "", locations ? {}, ... }: {
    locations = locations // {
      "/" = {
        extraConfig = ''
          auth_request     /outpost.goauthentik.io/auth/nginx;
          error_page       401 = @goauthentik_proxy_signin;
          auth_request_set $auth_cookie $upstream_http_set_cookie;
          add_header       Set-Cookie $auth_cookie;

          # translate headers from the outposts back to the actual upstream
          auth_request_set $authentik_username $upstream_http_x_authentik_username;
          auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
          auth_request_set $authentik_email $upstream_http_x_authentik_email;
          auth_request_set $authentik_name $upstream_http_x_authentik_name;
          auth_request_set $authentik_uid $upstream_http_x_authentik_uid;

          proxy_set_header X-authentik-username $authentik_username;
          proxy_set_header X-authentik-groups $authentik_groups;
          proxy_set_header X-authentik-email $authentik_email;
          proxy_set_header X-authentik-name $authentik_name;
          proxy_set_header X-authentik-uid $authentik_uid;
        '' + rootExtraConfig;
      } // root;
      # all requests to /outpost.goauthentik.io must be accessible without authentication
      "/outpost.goauthentik.io" = {
        extraConfig = ''
          proxy_pass              http://127.0.0.1:9000/outpost.goauthentik.io;
          proxy_set_header        Host $host;
          proxy_set_header        X-Original-URL $scheme://$http_host$request_uri;
          add_header              Set-Cookie $auth_cookie;
          auth_request_set        $auth_cookie $upstream_http_set_cookie;
          proxy_pass_request_body off;
          proxy_set_header        Content-Length "";
        '';
      };
      # Special location for when the /auth endpoint returns a 401, redirect to the /start URL which initiates SSO
      "@goauthentik_proxy_signin" = {
        extraConfig = ''
          internal;
          add_header Set-Cookie $auth_cookie;
          # return 302 /outpost.goauthentik.io/start?rd=$request_uri;
          # For domain level, use the below error_page to redirect to your authentik server with the full redirect path
          return 302 https://auth.ataraxiadev.com/outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
        '';
      };
    };
  };
in {
  security.acme.certs = {
    "ataraxiadev.com" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = [
        "startpage.ataraxiadev.com"
        "vw.ataraxiadev.com"
        "code.ataraxiadev.com"
        "fb.ataraxiadev.com"
        "browser.ataraxiadev.com"
        "webmail.ataraxiadev.com"
        "jellyfin.ataraxiadev.com"
        "medusa.ataraxiadev.com"
        "qbit.ataraxiadev.com"
        "jackett.ataraxiadev.com"
        "ldap.ataraxiadev.com"
        "bathist.ataraxiadev.com"
        "joplin.ataraxiadev.com"
        "api.ataraxiadev.com"
        "fsync.ataraxiadev.com"
        "auth.ataraxiadev.com"
        "sonarr.ataraxiadev.com"
        "radarr.ataraxiadev.com"
        "file.ataraxiadev.com"
        "lidarr.ataraxiadev.com"
        "cocalc.ataraxiadev.com"
        "kavita.ataraxiadev.com"
        "tools.ataraxiadev.com"
        "home.ataraxiadev.com"

        "matrix.ataraxiadev.com"
        "cinny.ataraxiadev.com"
        "dimension.ataraxiadev.com"
        "stats.ataraxiadev.com"
        "element.ataraxiadev.com"
      ];
    };
  };

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
    group = config.services.nginx.group;
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
      # proxy_hide_header Content-Security-Policy;
      # add_header Content-Security-Policy "upgrade-insecure-requests";
      # add_header X-XSS-Protection "1; mode=block";
      # add_header X-Robots-Tag "none";
      # add_header X-Content-Type-Options "nosniff";

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
      hardened = ''
        add_header Content-Security-Policy "frame-ancestors 'self' https://*.ataraxiadev.com";
        add_header Referrer-Policy "strict-origin-when-cross-origin";
      '';
    in {
      # "ataraxiadev.com" = default // authentik {
      #   root = { proxyPass = "http://127.0.0.1:3000"; };
      #   rootExtraConfig = ''
      #     if ($http_origin ~* "^https?://\w*\.?ataraxiadev\.com$") {
      #         add_header Access-Control-Allow-Origin "$http_origin";
      #     }
      #   '' + proxySettings;
      # };
      "ataraxiadev.com" = {
        locations."/" = {
          root = "/srv/http/ataraxiadev.com/docroot";
          extraConfig = ''
            try_files $uri $uri/ =404;
          '';
        };
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
          "stats.ataraxiadev.com"
        ];
        listen = [{
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }];
        locations."/" = {
          proxyPass = "http://matrix.pve:81";
          extraConfig = ''
            # proxy_hide_header Content-Security-Policy;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            client_max_body_size 50M;
          '';
        };
      } // default;
      "matrix:8448" = with config.security.acme; {
        serverAliases = [ "matrix.ataraxiadev.com" ];
        listen = [{
          addr = "0.0.0.0";
          port = 8448;
          ssl = true;
        }];
        locations."/" = {
          proxyPass = "http://matrix.pve:8449";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
            client_max_body_size 50M;
          '';
        };
      } // default;
      "home.ataraxiadev.com" = default // authentik {
        root = { proxyPass = "http://127.0.0.1:3000"; };
      };
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
      "code.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:6000";
          extraConfig = proxySettings;
        };
      } // default;
      # "bathist.ataraxiadev.com" = {
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:9999";
      #     extraConfig = proxySettings;
      #   };
      # } // default;
      "bathist.ataraxiadev.com" = default // authentik {
        root = { proxyPass = "http://127.0.0.1:9999"; };
        rootExtraConfig = proxySettings;
      };
      "browser.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8090";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_read_timeout 86400;
          '' + proxySettings;
        };
      } // default;
      "fb.ataraxiadev.com" = default // authentik {
        root = { proxyPass = "http://127.0.0.1:3923"; };
        rootExtraConfig = ''
          proxy_redirect off;
          proxy_http_version 1.1;
          client_max_body_size 0;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_set_header Connection "Keep-Alive";
        '' + proxySettings;
      };
      "file.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8088";
          extraConfig = ''
            client_max_body_size 0;
            proxy_buffer_size 16k;
            proxy_busy_buffers_size 16k;
            proxy_connect_timeout 36000s;
            proxy_max_temp_file_size 102400m;
            proxy_read_timeout 36000s;
            proxy_request_buffering off;
            send_timeout 36000s;
            proxy_send_timeout 36000s;
            # proxy_buffering off;
          '' + proxySettings;
        };
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
        '';
      } // default;
      "webmail.ataraxiadev.com" = {
        locations."/" = {
          extraConfig = ''
            client_max_body_size 30M;
          '' + proxySettings;
        };
      } // default;
      "cocalc.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "https://localhost:9099";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
      } // default;
      "tools.ataraxiadev.com" = default // authentik {
        root = { proxyPass = "http://127.0.0.1:8070"; };
      };
      "media-stack" = {
        serverAliases = [
          "jellyfin.ataraxiadev.com"
          "qbit.ataraxiadev.com"
          "medusa.ataraxiadev.com"
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
            # For Medusa
            add_header Content-Security-Policy "upgrade-insecure-requests";

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
      # "microbin.ataraxiadev.com" = {
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:9988";
      #     extraConfig = ''
      #       client_max_body_size 40M;
      #     '' + proxySettings;
      #   };
      # } // default;
      "joplin.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:22300";
          extraConfig = proxySettings;
        };
      } // default;
      "fsync.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:5000";
          extraConfig = proxySettings;
        };
      } // default;
      "auth.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
      } // default;
      "ldap.ataraxiadev.com" = default;
      "api.ataraxiadev.com" = {
        locations."~ (\\.py|\\.sh)$" = with config.services; {
          alias = "/srv/http/api.ataraxiadev.com";
          extraConfig = ''
            gzip off;
            fastcgi_pass ${fcgiwrap.socketType}:${fcgiwrap.socketAddress};
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include ${pkgs.nginx}/conf/fastcgi_params;
          '';
        };
      } // default;
    };
  };

  secrets.narodmon-key.owner = config.services.nginx.user;

  system.activationScripts.linkPyScripts.text = ''
    [ ! -d "/srv/http/api.ataraxiadev.com" ] && mkdir -p /srv/http/api.ataraxiadev.com
    ln -sfn ${pkgs.narodmon-py}/bin/temp.py /srv/http/api.ataraxiadev.com/temp.py
  '';

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}
