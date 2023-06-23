{ config, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces;
in {
  services.resolved = {
    enable = true;
    dnssec = "false";
  };
  networking = {
    enableIPv6 = true;
    usePredictableInterfaceNames = true;
    useDHCP = false;
    dhcpcd.enable = false;

    # nftables.enable = true;
    domain = "wg.ataraxiadev.com";
  };
  # enp0s18
  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "lo" ];
    networks = {
      "10-wan" = with interfaces.main'; {
        matchConfig.Name = ifname;
        address = [ IPv4.address IPv6.address ];
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
        linkConfig.RequiredForOnline = true;
        domains = [ config.networking.domain ];
        networkConfig = {
          DHCP = "no";
          IPForward = true;
          IPv6PrivacyExtensions = true;
          LinkLocalAddressing = "ipv6";
          IPv6AcceptRA = true;

          DNS = IPv4.dns ++ IPv6.dns;
        };
      };
    };
  };
}