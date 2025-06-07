{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) concatLists filter;
  inherit (lib)
    getExe
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    ;
  inherit (lib.types)
    bool
    listOf
    nullOr
    str
    submodule
    ;
  cfg = config.ataraxia.networkd;

  ipAddressType = submodule {
    options = {
      address = mkOption {
        type = str;
      };
      gateway = mkOption {
        type = nullOr str;
        default = null;
      };
      dns = mkOption {
        type = listOf str;
        default = [ ];
      };
      gatewayOnLink = mkEnableOption "Enable GatewayOnLink";
    };
  };
in
{
  options.ataraxia.networkd = {
    enable = mkEnableOption "Enable systemd-networkd bridged network";
    disableIPv6 = mkEnableOption "Enable IPv6";
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
    # TODO: implement disabling bridge
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
    ipv4 = mkOption {
      type = listOf ipAddressType;
      default = [ ];
    };
    ipv6 = mkOption {
      type = listOf ipAddressType;
      default =
        if !cfg.disableIPv6 then
          [
            {
              address = "fc00::1/64";
            }
          ]
        else
          [ ];
    };
  };

  config = mkIf cfg.enable {
    services.resolved.enable = true;
    networking = {
      dhcpcd.enable = false;
      domain = cfg.domain;
      enableIPv6 = !cfg.disableIPv6;
      nftables.enable = true;
      useDHCP = false;
      useNetworkd = true;
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
          address = map (ip: ip.address) (cfg.ipv4 ++ cfg.ipv6);
          dns = concatLists (map (ip: ip.dns) (cfg.ipv4 ++ cfg.ipv6));
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "routable";
          routes =
            let
              filteredRoutes = filter (ip: ip.gateway != null) (cfg.ipv4 ++ cfg.ipv6);
              routes = map (x: {
                Gateway = x.gateway;
                GatewayOnLink = x.gatewayOnLink;
              }) filteredRoutes;
            in
            routes;
        };
      };
    };

    system.activationScripts.udp-gro-forwarding = mkIf cfg.bridge.enable {
      text = ''
        ${getExe pkgs.ethtool} -K ${cfg.bridge.name} rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
