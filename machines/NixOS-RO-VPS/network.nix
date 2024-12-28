{ config, lib, pkgs, ... }:
let
  inherit (import ./hardware/networks.nix) interfaces domain hasIPv6;
in {
  services.resolved.enable = true;
  networking = {
    dhcpcd.enable = false;
    domain = domain;
    enableIPv6 = hasIPv6;
    hostName = config.device;
    nftables.enable = true;
    useDHCP = false;
    useNetworkd = lib.mkForce false;
    usePredictableInterfaceNames = true;

    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkDefault [ ];
      allowedUDPPorts = lib.mkDefault [ ];
    };

    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  systemd.network = with interfaces.main'; {
    enable = lib.mkForce true;
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
        ] ++ lib.optionals hasIPv6 [
          IPv6.address
          "fc00::1/64"
        ];
        linkConfig.RequiredForOnline = "routable";
        # networkConfig = {
        #   IPForward = true;
        #   DNS = IPv4.dns ++ lib.optionals hasIPv6 IPv6.dns;
        # };
        routes = [{
          Gateway = IPv4.gateway;
          GatewayOnLink = true;
        }] ++ lib.optionals hasIPv6 [{
          Gateway = IPv6.gateway;
          GatewayOnLink = true;
        }];
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