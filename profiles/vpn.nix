{ config, lib, pkgs, secretsDir, ... }:
let
  isTailscale = config.deviceSpecific.vpn.tailscale.enable;
  wg = config.deviceSpecific.vpn.wireguard;
  sing-box = config.deviceSpecific.vpn.sing-box;
  wgIFName = "wg0";
  isRouteAll = (builtins.elem "0.0.0.0/0" wg.allowedIPs) || (builtins.elem "::0/0" wg.allowedIPs);
in {
  config = lib.mkMerge [
    (lib.mkIf sing-box.enable {
      sops.secrets.${sing-box.config} = {
        sopsFile = secretsDir + /proxy.yaml;
        restartUnits = [ "sing-box.service" ];
        mode = "0600";
      };
      systemd.packages = [ pkgs.sing-box ];
      systemd.services.sing-box = {
        preStart = ''
          umask 0077
          mkdir -p /etc/sing-box
          cp ${config.sops.secrets.${sing-box.config}.path} /etc/sing-box/config.json
        '';
        wantedBy = [ "multi-user.target" ];
      };
    })
    (lib.mkIf isTailscale {
      services.tailscale.enable = true;
      services.tailscale.useRoutingFeatures = "client";
      persist.state.directories = [ "/var/lib/tailscale" ];
    })
    # TODO: currently broken, i'm using wg-quick for now
    (lib.mkIf wg.enable {
      networking.useNetworkd = false;
      systemd.network = {
        enable = false;
        wait-online.ignoredInterfaces = lib.optionals (!isRouteAll) [ wgIFName ];
        netdevs."90-${wgIFName}" = {
          netdevConfig = {
            Name = wgIFName;
            Kind = "wireguard";
            Description = "${wgIFName} - wireguard tunnel";
          };
          wireguardConfig = {
            PrivateKeyFile = wg.keys.privateFile;
            FirewallMark = 34952; # 0x8888
            ListenPort = wg.port + 1;
          };
          wireguardPeers = [{
            wireguardPeerConfig = {
              PublicKey = wg.keys.public;
              PresharedKeyFile = wg.keys.presharedFile;
              AllowedIPs = lib.concatStringsSep "," wg.allowedIPs;
              Endpoint = wg.endpoint;
              PersistentKeepalive = 25;
            };
          }];
        };
        networks."90-${wgIFName}" = {
          matchConfig.Name = wgIFName;
          address = wg.address;
          linkConfig.ActivationPolicy = if wg.autostart then "up" else "manual";
          networkConfig = {
            # IPForward = true;
            # IPMasquerade = "both";
            DNSDefaultRoute = true;
            DNS = wg.dns;
            Domains = "~";
          };
          routes = lib.optionals (isRouteAll && wg.gateway.ipv4 != null) [
            {
              routeConfig.Gateway = wg.gateway.ipv4;
              routeConfig.Destination = "0.0.0.0/0";
              routeConfig.GatewayOnLink = true;
              routeConfig.Table = 1000;
            }
            {
              routeConfig.Gateway = wg.gateway.ipv6;
              routeConfig.GatewayOnLink = true;
              routeConfig.Table = 1000;
            }
          ];
          routingPolicyRules = lib.optionals (isRouteAll && wg.gateway != null) [{
            routingPolicyRuleConfig.FirewallMark = 34952; # 0x8888
            routingPolicyRuleConfig.InvertRule = true;
            routingPolicyRuleConfig.Table = 1000;
            routingPolicyRuleConfig.Priority = 10;
          }];
        };
      };
    })
  ];
}
