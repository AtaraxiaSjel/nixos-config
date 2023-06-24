{ config, lib, pkgs, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces wireguardPort wireguardPeers;
  wireguardIFName = interfaces.wireguard0.ifname;
  ataraxiaPeerAddresses = with wireguardPeers.ataraxia; [ "${IPv4}/32" "${IPv6}/128" ];
in {
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.firewall = {
    allowedUDPPorts = [ wireguardPort ];
    checkReversePath = false;
  };

  boot.kernelModules = [ "wireguard" ];
  systemd.network = {
    wait-online.ignoredInterfaces = [ wireguardIFName ];

    netdevs."90-${wireguardIFName}" = {
      netdevConfig = {
        Name = wireguardIFName;
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = "/var/lib/wireguard/private";
        ListenPort = wireguardPort;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "qjkV4V0on7H3hXG7udKOv4Qu/IUBrsDcXNZt3MupP3o=";
            PresharedKeyFile = "/var/lib/wireguard/ataraxia-psk";
            AllowedIPs = lib.concatStringsSep "," ataraxiaPeerAddresses;
          };
        }
      ];
    };

    networks."90-${wireguardIFName}" = with interfaces.wireguard0; {
      matchConfig.Name = wireguardIFName;
      address = [
        "${IPv4.address}/16"
        "${IPv6.address}/64"
      ];
      linkConfig = {
        MTUBytes = "1360";
      };
      DHCP = "no";
      networkConfig = {
        IPForward = true;
        IPMasquerade = "both";
        # Quad9 dns
        DNS = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
      };
    };
  };
}
