{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  ataraxia.services.tor.enableRelay = false;
  ataraxia.services.tor.relayPort = 19361;
  ataraxia.containers.remnawave-node.enable = true;
  ataraxia.containers.remnawave-node.port = 2764;
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
        use_backend backend_vless_ru if { req_ssl_sni -i disk.ataraxiadev.com }
        use_backend backend_vless_public if { req_ssl_sni -i media-01.ataraxiadev.com }
        use_backend backend_vless_private if { req_ssl_sni -i media-02.ataraxiadev.com }
        default_backend backend_caddy_https

      backend backend_caddy_http
        mode tcp
        server caddy_http 127.0.0.1:8080 send-proxy-v2 check

      backend backend_caddy_https
        mode tcp
        server caddy_https 127.0.0.1:8443 send-proxy-v2 check

      backend backend_vless_ru
        mode tcp
        server vless_ru 127.0.0.1:10443 send-proxy-v2 check

      backend backend_vless_public
        mode tcp
        server vless_public 127.0.0.1:10444 send-proxy-v2 check

      backend backend_vless_private
        mode tcp
        server vless_private 127.0.0.1:10445 send-proxy-v2 check
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
      https://disk.ataraxiadev.com {
        reverse_proxy 127.0.0.1:8081
        header -Server
      }
      https://media-01.ataraxiadev.com {
        reverse_proxy 127.0.0.1:8081
        header -Server
      }
      https://media-02.ataraxiadev.com {
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
