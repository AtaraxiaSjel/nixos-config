{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    optionals
    ;
  inherit (lib.types)
    bool
    listOf
    nullOr
    str
    ;
  cfg = config.ataraxia.network;
in
{
  options.ataraxia.network = {
    enable = mkEnableOption "Enable systemd-networkd bridged network";
    enableIPv6 = mkEnableOption "Enable IPv6";
    domain = mkOption {
      type = nullOr str;
      default = null;
    };
    ifname = mkOption {
      type = str;
    };
    mac = mkOption {
      type = str;
    };
    bridge = {
      enable = mkOption {
        type = bool;
        default = true;
      };
      name = mkOption {
        type = str;
        default = "br0";
      };
    };
    ipv4 = {
      address = mkOption {
        type = str;
      };
      gateway = mkOption {
        type = str;
      };
      dns = mkOption {
        type = listOf str;
        default = [ ];
      };
      gatewayOnLink = mkEnableOption "Enable GatewayOnLink";
    };
    ipv6 = {
      address = mkOption {
        type = str;
      };
      gateway = mkOption {
        type = str;
      };
      dns = mkOption {
        type = listOf str;
        default = [ ];
      };
      gatewayOnLink = mkEnableOption "Enable GatewayOnLink";
    };
  };

  config = mkIf cfg.enable {
    services.resolved.enable = true;
    networking = {
      dhcpcd.enable = false;
      domain = mkIf (cfg ? domain) cfg.domain;
      enableIPv6 = cfg.enableIPv6;
      nftables.enable = true;
      useDHCP = false;
      useNetworkd = false;
      usePredictableInterfaceNames = mkForce true;
      firewall = {
        enable = true;
        allowedTCPPorts = mkDefault [ ];
        allowedUDPPorts = mkDefault [ ];
      };
    };

    systemd.network = {
      enable = true;
      wait-online.ignoredInterfaces = [ "lo" ];
      netdevs = {
        "20-${cfg.bridge.name}" = {
          netdevConfig = {
            Kind = "bridge";
            Name = cfg.bridge.name;
            MACAddress = cfg.mac;
          };
        };
      };
      networks = {
        "30-${cfg.ifname}" = {
          matchConfig.Name = cfg.ifname;
          linkConfig.RequiredForOnline = "enslaved";
          networkConfig.Bridge = cfg.bridge.name;
          networkConfig.DHCP = "no";
        };
        "40-${cfg.bridge.name}" = {
          matchConfig.Name = cfg.bridge.name;
          address =
            [
              cfg.ipv4.address
            ]
            ++ optionals cfg.enableIPv6 [
              cfg.ipv6.address
              "fc00::1/64"
            ];
          dns = cfg.ipv4.dns ++ optionals cfg.enableIPv6 cfg.ipv6.dns;
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "routable";
          routes =
            [
              {
                Gateway = cfg.ipv4.gateway;
                GatewayOnLink = mkIf cfg.ipv4.gatewayOnLink true;
              }
            ]
            ++ optionals cfg.enableIPv6 [
              {
                Gateway = cfg.ipv6.gateway;
                GatewayOnLink = mkIf cfg.ipv4.gatewayOnLink true;
              }
            ];
        };
      };
    };

    system.activationScripts.udp-gro-forwarding = mkIf cfg.bridge.enable {
      text = ''
        ${pkgs.ethtool}/bin/ethtool -K ${cfg.bridge.name} rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
