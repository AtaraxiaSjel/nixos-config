{ config, ... }:
let
  cert-fqdn = "ataraxiadev.com";
in {
  virtualisation.libvirt.guests.debian-matrix = {
    autoStart = true;
    user = config.mainuser;
    group = "libvirtd";
    xmlFile = ./vm.xml;
  };

  networking = let
    libvirt-ifname = "virbr0";
    guest-ip = "192.168.122.11";
    synapse-ports = [ 8081 8448 8766 ];
  in {
    firewall.allowedTCPPorts = synapse-ports;
    nat = {
      enable = true;
      internalInterfaces = [ "br0" ];
      externalInterface = libvirt-ifname;
      forwardPorts = [{
        sourcePort = 8081;
        proto = "tcp";
        destination = "${guest-ip}:8081";
      } {
        sourcePort = 8448;
        proto = "tcp";
        destination = "${guest-ip}:8448";
      } {
        sourcePort = 8766;
        proto = "tcp";
        destination = "${guest-ip}:8766";
      }];
    };
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
        proxyPass = "http://192.168.122.11:8081";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
        '' + proxySettings;
      };
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
        proxyPass = "http://192.168.122.11:8448";
        extraConfig = proxySettings;
      };
    } // default;
  };
}
