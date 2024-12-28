{ config, pkgs, inputs, ... }:
let
  authentik = { proxyPass ? null, proxyWebsockets ? false, root ? {}, rootExtraConfig ? "", locations ? {}, extraConfig ? "", ... }: {
    extraConfig = ''
      proxy_buffers 8 16k;
      proxy_buffer_size 32k;
    '' + extraConfig;
    locations = locations // {
      "/" = {
        proxyPass = proxyPass;
        proxyWebsockets = proxyWebsockets;
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
          auth_request_set $authentik_authorization $upstream_http_authorization;

          proxy_set_header X-authentik-username $authentik_username;
          proxy_set_header X-authentik-groups $authentik_groups;
          proxy_set_header X-authentik-email $authentik_email;
          proxy_set_header X-authentik-name $authentik_name;
          proxy_set_header X-authentik-uid $authentik_uid;
          proxy_set_header Authorization $authentik_authorization;
        '' + rootExtraConfig;
      } // root;
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
      "@goauthentik_proxy_signin" = {
        extraConfig = ''
          internal;
          add_header Set-Cookie $auth_cookie;
          return 302 /outpost.goauthentik.io/start?rd=$request_uri;
          # For domain level, use the below error_page to redirect to your authentik server with the full redirect path
          # return 302 https://auth.ataraxiadev.com/outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
        '';
      };
    };
  };
in {
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
      hardened = ''
        add_header Content-Security-Policy "frame-ancestors 'self' https://*.ataraxiadev.com";
        add_header Referrer-Policy "strict-origin-when-cross-origin";
      '';
    in {
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
        locations."/.well-known/matrix" = {
          proxyPass = "https://matrix.ataraxiadev.com/.well-known/matrix";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
          '';
        };
      } // default;
      "api.ataraxiadev.com" = {
        locations."~ (\\.py)$" = with config.services; {
          alias = "/srv/http/api.ataraxiadev.com";
          extraConfig = ''
            gzip off;
            fastcgi_pass ${fcgiwrap.socketType}:${fcgiwrap.socketAddress};
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include ${pkgs.nginx}/conf/fastcgi_params;
          '';
        };
      } // default;
      "auth.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
      } // default;
      "cache.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8083";
          extraConfig = ''
            client_max_body_size 0;
            send_timeout 15m;
          '' + proxySettings;
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
      "docs.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3010";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 100M;
          '' + proxySettings;
        };
      } // default;
      "file.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9200";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_buffers 4 256k;
            proxy_buffer_size 128k;
            proxy_busy_buffers_size 256k;
            # Disable checking of client request body size
            client_max_body_size 0;
          '';
        };
      } // default;
      "home.ataraxiadev.com" = default // authentik {
        proxyPass = "http://127.0.0.1:3000";
      };
      "joplin.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:22300";
          extraConfig = proxySettings;
        };
      } // default;
      "ldap.ataraxiadev.com" = default;
      "lib.ataraxiadev.com" = default // authentik {
        proxyPass = "http://127.0.0.1:8072";
        proxyWebsockets = true;
      };
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
      "openbooks.ataraxiadev.com" = default // authentik {
        proxyPass = "http://127.0.0.1:8097";
        proxyWebsockets = true;
      };
      "pdf.ataraxiadev.com" = default // authentik {
        proxyPass = "http://127.0.0.1:8071";
      };
      "s3.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9600";
          extraConfig = ''
            proxy_connect_timeout 300;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;
          '' + proxySettings;
        };
        locations."/ui/" = {
          proxyPass = "http://127.0.0.1:9601";
          extraConfig = ''
            rewrite ^/ui/(.*) /$1 break;
            proxy_set_header X-NginX-Proxy true;
            real_ip_header X-Real-IP;

            proxy_connect_timeout 300;
            chunked_transfer_encoding off;
          '' + proxySettings;
          proxyWebsockets = true;
        };
        extraConfig = ''
          ignore_invalid_headers off;
          client_max_body_size 0;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      } // default;
      "stats.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9002";
          extraConfig = proxySettings;
        };
        locations."/api/live/" = {
          proxyPass = "http://127.0.0.1:9002";
          proxyWebsockets = true;
          extraConfig = proxySettings;
        };
      } // default;
      "tools.ataraxiadev.com" = default // authentik {
        proxyPass = "http://127.0.0.1:8070";
      };
      "vault.ataraxiadev.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8200";
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
      "wiki.ataraxiadev.com" = default // authentik {
        proxyPass = "http://127.0.0.1:8190";
      };
      "wopi.ataraxiadev.com" = default // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8880";
        };
      };
    };
  };

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
    group = config.services.nginx.group;
  };

  sops.secrets.narodmon-key.sopsFile = inputs.self.secretsDir + /home-hypervisor/api.yaml;
  sops.secrets.narodmon-key.owner = config.services.nginx.user;
  # Avoid api key revoke
  systemd.services.narodmon-api = {
    serviceConfig = {
      Type = "oneshot";
      User = config.services.nginx.user;
      ExecStart = "${pkgs.narodmon-py}/bin/temp.py";
    };
    startAt = "daily";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  system.activationScripts.linkPyScripts.text = ''
    [ ! -d "/srv/http/api.ataraxiadev.com" ] && mkdir -p /srv/http/api.ataraxiadev.com
    ln -sfn ${pkgs.narodmon-py}/bin/temp.py /srv/http/api.ataraxiadev.com/temp.py
  '';

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
