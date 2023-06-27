{ config, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces;
in {
  services.resolved.enable = true;
  networking = {
    enableIPv6 = true;
    usePredictableInterfaceNames = true;
    useDHCP = false;
    dhcpcd.enable = false;
    nftables.enable = true;
    domain = "wg.ataraxiadev.com";
  };
  systemd.network = with interfaces.main'; {
    enable = true;
    wait-online.ignoredInterfaces = [ "lo" ];
    networks = {
      "10-wan" = {
        matchConfig.Name = ifname;
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig.Bridge = bridgeName;
        networkConfig.DHCP = "no";
        networkConfig.LinkLocalAddressing = "no";
        networkConfig.IPv6AcceptRA = false;
      };
      "20-${bridgeName}" = {
        matchConfig.Name = bridgeName;
        address = [
          IPv4.address IPv6.address
          "192.168.0.1/24" "fc00::1/64"
        ];
        linkConfig.RequiredForOnline = "routable";

        domains = [ config.networking.domain ];
        networkConfig = {
          DHCP = "no";
          IPForward = true;
          IPv6PrivacyExtensions = true;
          LinkLocalAddressing = "no";
          IPv6AcceptRA = false;
          DNS = IPv4.dns ++ IPv6.dns;
        };
        routes = [
          {
            routeConfig.Gateway = IPv4.gateway;
            routeConfig.GatewayOnLink = true;
          }
          {
            routeConfig.Gateway = IPv6.gateway;
            routeConfig.GatewayOnLink = true;
          }
        ];
      };
    };
    netdevs = {
      "20-${bridgeName}" = {
        netdevConfig = {
          Kind = "bridge";
          Name = bridgeName;
          MACAddress = "e6:95:b5:a6:28:c0";
        };
      };
    };
  };
}