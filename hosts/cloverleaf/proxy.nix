{ pkgs, ... }:
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
        server vless 127.0.0.1:10443 send-proxy-v2 check

      backend backend_telemt
        mode tcp
        server telemt 127.0.0.1:20443 send-proxy-v2 check
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
}
