{ config, lib, inputs, ... }:
let
  bridge = (import ../hardware/networks.nix).interfaces.main';
  external-ip = "83.138.55.118";
  coturn-denied-ips = [
    "0.0.0.0-0.255.255.255"
    "10.0.0.0-10.255.255.255"
    "100.64.0.0-100.127.255.255"
    "127.0.0.0-127.255.255.255"
    "169.254.0.0-169.254.255.255"
    "172.16.0.0-172.31.255.255"
    "192.0.0.0-192.0.0.255"
    "192.0.2.0-192.0.2.255"
    "192.88.99.0-192.88.99.255"
    "192.168.0.0-192.168.255.255"
    "198.18.0.0-198.19.255.255"
    "198.51.100.0-198.51.100.255"
    "203.0.113.0-203.0.113.255"
    "240.0.0.0-255.255.255.255"
    "::1"
    "64:ff9b::-64:ff9b::ffff:ffff"
    "::ffff:0.0.0.0-::ffff:255.255.255.255"
    "100::-100::ffff:ffff:ffff:ffff"
    "2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff"
    "2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
    "fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
    "fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
  ];
  cert-fqdn = "matrix.ataraxiadev.com";
in {
  security.acme = {
    acceptTerms = true;
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory";
    defaults.email = "admin@ataraxiadev.com";
    defaults.renewInterval = "weekly";
    certs.${cert-fqdn} = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = [
        "element.ataraxiadev.com"
        "turn.ataraxiadev.com"
      ];
    };
  };

  sops.secrets.auth-secret = {
    sopsFile = inputs.self.secretsDir + /nixos-vps/coturn.yaml;
    restartUnits = [ "coturn.service" ];
    owner = config.users.users.turnserver.name;
    mode = "0400";
  };

  virtualisation.libvirt.guests.debian-matrix = {
    autoStart = true;
    user = config.mainuser;
    group = "libvirtd";
    xmlFile = ../vm/debian-matrix.xml;
  };

  services.coturn = {
    enable = true;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets.auth-secret.path;
    realm = "turn.ataraxiadev.com";
    min-port = 49152;
    max-port = 49262;
    no-cli = true;
    cert = "${config.security.acme.certs.${cert-fqdn}.directory}/fullchain.pem";
    pkey = "${config.security.acme.certs.${cert-fqdn}.directory}/key.pem";
    no-tcp-relay = true;
    extraConfig = ''
      external-ip=${external-ip}
      userdb=/var/lib/coturn/turnserver.db
      no-tlsv1
      no-tlsv1_1
      no-rfc5780
      no-stun-backward-compatibility
      response-origin-only-with-rfc5780
      no-multicast-peers
    '' + lib.strings.concatMapStringsSep "\n" (x: "denied-peer-ip=${x}")
      coturn-denied-ips;
  };
  systemd.services.coturn.serviceConfig.StateDirectory = "coturn";
  systemd.services.coturn.serviceConfig.Group = lib.mkForce "acme";

  networking = let
    libvirt-ifname = "virbr0";
    guest-ip = "192.168.122.11";
    synapse-ports = [ 8081 8448 8766 ];
    turn-ports = with config.services.coturn; [
      listening-port tls-listening-port
      alt-listening-port alt-tls-listening-port
    ];
  in {
    firewall = {
      allowedUDPPortRanges = with config.services.coturn; [{
        from = min-port;
        to = max-port;
      }];
      allowedUDPPorts = turn-ports;
      allowedTCPPorts = turn-ports ++ synapse-ports;
    };
    nat = {
      enable = true;
      internalInterfaces = [ bridge.bridgeName ];
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
}
