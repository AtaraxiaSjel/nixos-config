{
  config,
  pkgs,
  secretsDir,
  ...
}:
let
  hostname = config.networking.hostName;
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  ataraxia.services.tor.enableRelay = true;
  ataraxia.services.tor.relayPort = 18467;
  ataraxia.containers.remnawave-node.enable = true;
  ataraxia.services.telemt.enable = true;
  services.filebrowser = {
    enable = true;
    settings.port = 8081;
    settings.root = "/srv/filebrowser";
  };
  services.haproxy = {
    enable = true;
    config = ''
      log /dev/log local0
      defaults
        log     global
        mode    tcp
        option  tcplog
        option  dontlog-normal
        option  dontlognull

        timeout client 30s
        timeout client-fin 30s
        timeout connect 30s
        timeout server 30s
        timeout tunnel 1h
        timeout http-request 20s

      frontend http_in
        bind *:80
        mode tcp
        default_backend backend_caddy_http

      frontend https_sni_router
        bind *:443
        mode tcp
        tcp-request inspect-delay 5s
        tcp-request content accept if { req_ssl_hello_type 1 }
        use_backend backend_vless if { req_ssl_sni -i panel.ataraxiadev.com }
        use_backend backend_vless_bridge if { req_ssl_sni -i cloud-02.ataraxiadev.com }
        use_backend backend_telemt if { req_ssl_sni -i panel-tg.ataraxiadev.com }
        default_backend backend_caddy_https

      backend backend_caddy_http
        mode tcp
        server caddy_http 127.0.0.1:8080 send-proxy-v2 check

      backend backend_caddy_https
        mode tcp
        server caddy_https 127.0.0.1:8443 send-proxy-v2 check

      backend backend_vless
        mode tcp
        server vless 127.0.0.1:10443 send-proxy-v2

      backend backend_vless_bridge
        mode tcp
        server vless_bridge 127.0.0.1:10444 send-proxy-v2

      backend backend_telemt
        mode tcp
        server telemt 127.0.0.1:20443 send-proxy-v2
    '';
  };
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      {
        http_port 8080
        https_port 8443
        servers :8443 {
          listener_wrappers {
            proxy_protocol {
              timeout 2s
              allow 127.0.0.1/32
            }
            tls
          }
        }
        servers :8080 {
          listener_wrappers {
            proxy_protocol {
              timeout 2s
              allow 127.0.0.1/32
            }
          }
        }
      }
      https://panel.ataraxiadev.com {
        reverse_proxy 127.0.0.1:8081
        header -Server
      }
      https://cloud-02.ataraxiadev.com {
        reverse_proxy 127.0.0.1:8081
        header -Server
      }
      https://panel-tg.ataraxiadev.com {
        reverse_proxy 127.0.0.1:8081
        header -Server
      }
      http://:8080 {
        abort
      }
      https://:8443 {
        tls internal
        abort
      }
    '';
  };

  networking.firewall.checkReversePath = "loose";
  sops.secrets."warp-${hostname}" = {
    sopsFile = secretsDir + /${hostname}/warp.yaml;
    mode = "640";
    owner = "systemd-network";
    group = "systemd-network";
  };
  systemd.network = {
    networks."50-warp" = {
      matchConfig.Name = "warp";
      address = [
        "172.16.0.2/32"
        "2606:4700:110:8bbf:1df3:7f98:71ec:6c2d/128"
      ];
      routingPolicyRules = [
        {
          FirewallMark = 51;
          Table = 51;
        }
      ];
      linkConfig.ActivationPolicy = "up";
    };
    netdevs."50-warp" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "warp";
        MTUBytes = "1280";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."warp-${hostname}".path;
      };
      wireguardPeers = [
        {
          PublicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
          AllowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          Endpoint = "162.159.192.1:2408";
          PersistentKeepalive = 25;
          RouteTable = 51;
        }
      ];
    };
  };
}
