{ config, lib, pkgs, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces domain hasIPv6;
in {
  services.resolved.enable = true;
  networking = {
    enableIPv6 = lib.mkForce hasIPv6;
    usePredictableInterfaceNames = lib.mkForce true;
    useDHCP = false;
    dhcpcd.enable = false;
    nftables.enable = false; # incompatible with tailscale and docker
    hostName = config.device;
    domain = domain;
    nameservers = with interfaces.main'; IPv4.dns ++ lib.optionals hasIPv6 IPv6.dns;
  };

  systemd.network = with interfaces.main'; {
    enable = true;
    wait-online.ignoredInterfaces = [ "lo" ];
    networks = {
      "40-${ifname}" = {
        matchConfig.Name = ifname;
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig.Bridge = bridgeName;
        networkConfig.DHCP = "no";
      };
      "60-${bridgeName}" = {
        matchConfig.Name = bridgeName;
        address = [
          IPv4.address
          "192.168.0.1/24"
        ] ++ lib.optionals hasIPv6 [
          IPv6.address
          "fc00::1/64"
        ];
        linkConfig.RequiredForOnline = "routable";
        routes = [{
          routeConfig.Gateway = IPv4.gateway;
          routeConfig.GatewayOnLink = true;
        }] ++ lib.optionals hasIPv6 [{
          routeConfig.Gateway = IPv6.gateway;
          routeConfig.GatewayOnLink = true;
        }];
        dhcpServerConfig = {
          ServerAddress = "192.168.0.1/24";
          PoolOffset = 100;
          PoolSize = 100;
        };
      };
    };
    netdevs = {
      "60-${bridgeName}" = {
        netdevConfig = {
          Kind = "bridge";
          Name = bridgeName;
          MACAddress = mac;
        };
      };
    };
  };

  system.activationScripts.udp-gro-forwarding = {
    text = with interfaces.main'; ''
      ${pkgs.ethtool}/bin/ethtool -K ${bridgeName} rx-udp-gro-forwarding on rx-gro-list off
    '';
  };
}