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
        DNS = interfaces.main'.IPv4.dns ++ interfaces.main'.IPv6.dns;
      };
    };

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
          wireguardPeerConfig = with wireguardPeers.ataraxia; {
            PublicKey = "qjkV4V0on7H3hXG7udKOv4Qu/IUBrsDcXNZt3MupP3o=";
            PresharedKeyFile = "/var/lib/wireguard/ataraxia/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.hypervisor; {
            PublicKey = "oKQ3HXZ1wwWyVgmA4RoCXscImohqB8hdMzP1FRArw0o=";
            PresharedKeyFile = "/var/lib/wireguard/hypervisor/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.mikrotik; {
            PublicKey = "amReLTZgu6pwtKCnk1q8EG5uZSgUNxRoh5m3w1D3rQo=";
            PresharedKeyFile = "/var/lib/wireguard/mikrotik/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.poco; {
            PublicKey = "ZbBJziuMjyHJNcgrLYIQtio7l3fEOJ4GXW4ST+N9V34=";
            PresharedKeyFile = "/var/lib/wireguard/poco/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.kpoxa; {
            PublicKey = "U1wtbS8/yQGkBnBQUZs7KxxmvAajKb9jh83dDd2LdgE=";
            PresharedKeyFile = "/var/lib/wireguard/kpoxa/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.kpoxa2; {
            PublicKey = "ghU3Puwz5PeXmnDlxyh+IeuwFK44V3rXlMiFGs5YnwI=";
            PresharedKeyFile = "/var/lib/wireguard/kpoxa2/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.faysss; {
            PublicKey = "JLvKyFwI7b9MsiZsnNAt3qs5ob18b3mrOZKR5HZCORY=";
            PresharedKeyFile = "/var/lib/wireguard/faysss/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.faysss2; {
            PublicKey = "S6k9l0K5/YmO5BPETQludC1CBHsKLsk9+n6kwSjx4n8=";
            PresharedKeyFile = "/var/lib/wireguard/faysss2/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.faysss3; {
            PublicKey = "ka42gE67gShu88Ko7iQ/pK8zusod6bNIrIN8fkxVkC4=";
            PresharedKeyFile = "/var/lib/wireguard/faysss3/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.doste; {
            PublicKey = "KVbEaO4DSpTb941zxOPQLWq2Glm9CDgK/9MwW95WuC0=";
            PresharedKeyFile = "/var/lib/wireguard/doste/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
        {
          wireguardPeerConfig = with wireguardPeers.dell; {
            PublicKey = "//ss9UEHRFEZL4LbZaA1HiRUrMrn97kc7CmblUORXTc=";
            PresharedKeyFile = "/var/lib/wireguard/dell/preshared";
            AllowedIPs = [ "${IPv4}/32" "${IPv6}/128" ];
          };
        }
      ];
    };
  };
}
