{ config, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces domain;
in {
  services.resolved.enable = true;
  networking = {
    enableIPv6 = true;
    usePredictableInterfaceNames = true;
    useDHCP = false;
    dhcpcd.enable = false;
    nftables.enable = false; # incompatible with tailscale and docker
    hostName = config.device;
    domain = domain;
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
          IPv6.address
          "192.168.0.1/24"
          "fc00::1/64"
        ];
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          DHCP = "no";
          IPForward = true;
          IPv6PrivacyExtensions = "kernel";
          DNS = IPv4.dns ++ IPv6.dns;
        };
        routes = [{
          routeConfig.Gateway = IPv4.gateway;
          routeConfig.GatewayOnLink = true;
        } {
          routeConfig.Gateway = IPv6.gateway;
          routeConfig.GatewayOnLink = true;
        }];
      };
    };
    netdevs = {
      "60-${bridgeName}" = {
        netdevConfig = {
          Kind = "bridge";
          Name = bridgeName;
          MACAddress = "72:df:16:d2:1b:d7";
        };
      };
    };
  };
}