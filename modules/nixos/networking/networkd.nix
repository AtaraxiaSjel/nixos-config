{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) all concatLists filter;
  inherit (lib)
    getExe
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    ;
  inherit (lib.types)
    bool
    either
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

  dnsV4Empty = all (ip: ip.dns == [ ]) cfg.ipv4;
  gatewayV4Empty = all (ip: ip.gateway == null) cfg.ipv4;
  dnsV6Empty = all (ip: ip.dns == [ ]) cfg.ipv6;
  dhcpConf =
    if (dnsV4Empty && dnsV6Empty) then
      "yes"
    else if dnsV4Empty then
      "ipv4"
    else if dnsV6Empty then
      "ipv6"
    else
      "no";
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
      type = either str (listOf str);
    };
    mac = mkOption {
      type = nullOr str;
      default = null;
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
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.bridge.enable && cfg.mac == null);
        message = "config.ataraxia.networkd.bridge.enable requires config.ataraxia.networkd.mac to be set";
      }
    ];

    # services.resolved.enable = !config.boot.isContainer;
    services.resolved.enable = true;
    networking = {
      dhcpcd.enable = false;
      domain = cfg.domain;
      enableIPv6 = !cfg.disableIPv6;
      nftables.enable = true;
      useDHCP = false;
      # useHostResolvConf = config.boot.isContainer;
      useHostResolvConf = false;
      useNetworkd = true;
      usePredictableInterfaceNames = mkForce true;
      firewall = {
        enable = true;
        allowedTCPPorts = mkDefault [ ];
        allowedUDPPorts = mkDefault [ ];
      };
    };

    systemd.network = mkMerge [
      {
        enable = true;
        wait-online.enable = false;
        wait-online.ignoredInterfaces = [ "lo" ];
      }
      (mkIf (!cfg.bridge.enable) {
        networks."50-wired" = {
          matchConfig = {
            Type = "ether";
            Name = cfg.ifname;
          };
          address = map (ip: ip.address) (cfg.ipv4 ++ cfg.ipv6);
          dns = concatLists (map (ip: ip.dns) (cfg.ipv4 ++ cfg.ipv6));
          networkConfig.LinkLocalAddressing = "ipv6";
          networkConfig.DHCP = dhcpConf;
          dhcpV4Config = mkIf dnsV4Empty {
            UseDNS = true;
            UseRoutes = false;
            UseGateway = gatewayV4Empty;
          };
          dhcpV6Config = mkIf (!cfg.disableIPv6 && dnsV6Empty) {
            UseDNS = true;
          };
          linkConfig.RequiredForOnline = "yes";
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
      })
      (mkIf cfg.bridge.enable {
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
          "30-wired" = {
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
            networkConfig.DHCP = dhcpConf;
            dhcpV4Config = mkIf dnsV4Empty {
              UseDNS = true;
              UseRoutes = false;
              UseGateway = gatewayV4Empty;
            };
            dhcpV6Config = mkIf (!cfg.disableIPv6 && dnsV6Empty) {
              UseDNS = true;
            };
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
      })
    ];

    system.activationScripts.udp-gro-forwarding = mkIf cfg.bridge.enable {
      text = ''
        ${getExe pkgs.ethtool} -K ${cfg.bridge.name} rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
