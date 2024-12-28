{ config, ... }:
let
  cert-fqdn = "ataraxiadev.com";
  guest-ip = "10.10.10.20";
in {
  virtualisation.libvirt.guests.debian-matrix = {
    autoStart = true;
    user = config.mainuser;
    group = "libvirtd";
    xmlFile = ./vm.xml;
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 8448 ];
    allowedUDPPorts = [ 443 8448 ];
  };

  services.nginx.virtualHosts = let
    proxySettings = ''
      client_max_body_size 50M;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
    default = {
      useACMEHost = cert-fqdn;
      enableACME = false;
      forceSSL = true;
    };
  in {
    "ataraxiadev.com" = {
      locations."/.well-known/matrix" = {
        proxyPass = "http://${guest-ip}:8080";
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host matrix.$host;
        '';
      };
    };
    "matrix:443" = {
      serverAliases = [
        "matrix.ataraxiadev.com"
        "element.ataraxiadev.com"
      ];
      listen = [{
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      } {
        addr = "[::]";
        port = 443;
        ssl = true;
      }];
      locations."/" = {
        proxyPass = "http://${guest-ip}:8080";
        extraConfig = proxySettings + ''
          proxy_set_header X-Real-IP $remote_addr;

          # required for browsers to direct them to quic port
          add_header Alt-Svc 'h3=":443"; ma=86400';
        '';
      };
      locations."/synapse-admin" = {
        proxyPass = "http://${guest-ip}:8080";
        extraConfig = proxySettings + ''
          proxy_set_header X-Real-IP $remote_addr;
          allow 10.10.10.1/24;
          allow 100.64.0.1/24;
          deny all;
        '';
      };
      reuseport = true;
      quic = true;
    } // default;
    "matrix:8448" = {
      serverAliases = [ "matrix.ataraxiadev.com" ];
      listen = [{
        addr = "0.0.0.0";
        port = 8448;
        ssl = true;
      } {
        addr = "[::]";
        port = 8448;
        ssl = true;
      }];
      locations."/" = {
        proxyPass = "http://${guest-ip}:8448";
        extraConfig = proxySettings + ''
          # required for browsers to direct them to quic port
          add_header Alt-Svc 'h3=":8448"; ma=86400';
        '';
      };
      reuseport = true;
      quic = true;
    } // default;
  };
}
