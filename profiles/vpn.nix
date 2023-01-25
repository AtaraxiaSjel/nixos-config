{ pkgs, lib, config, ... }:
let
  isMullvad = config.deviceSpecific.vpn.mullvad.enable;
  isTailscale = config.deviceSpecific.vpn.tailscale.enable;
in {
  config = lib.mkMerge [
    (lib.mkIf isMullvad {
      services.mullvad-vpn = {
        enable = true;
        enableExcludeWrapper = true;
        package = pkgs.mullvad-vpn;
      };
      startupApplications = [ "${pkgs.mullvad-vpn}/bin/mullvad-gui" ];
      persist.state.homeDirectories = [ ".config/Mullvad VPN" ];
      persist.cache.directories = [ "/var/cache/mullvad-vpn" ];
    })

    (lib.mkIf isTailscale {
      services.tailscale = {
        enable = true;
        #interfaceName = "userspace-networking";
        interfaceName = "tailscale0";
      };
      systemd.services.tailscaled.serviceConfig.ExecStart = [
        ""
        "${pkgs.mullvad}/bin/mullvad-exclude ${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=\${PORT} $FLAGS"
      ];
      persist.state.directories = [ "/var/lib/tailscale" ];
    })

    (lib.mkIf (isMullvad && isTailscale) {
      # FIXME: allow mullvad custom dns
      networking.nftables.ruleset = let
        resolver_addrs = "100.100.100.100";
        excluded_ipv4 = "100.64.0.1/10";
        excluded_ipv6 = "fd7a:115c:a1e0::/48";
      in ''
        table inet mullvad-ts {
          chain excludeOutgoing {
            type route hook output priority 0; policy accept;
            ip daddr ${excluded_ipv4} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
            ip6 daddr ${excluded_ipv6} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
          chain allow-incoming {
            type filter hook input priority -100; policy accept;
            iifname "${config.services.tailscale.interfaceName}" ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
          chain excludeDns {
            type filter hook output priority -10; policy accept;
            ip daddr ${resolver_addrs} udp dport 53 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
            ip daddr ${resolver_addrs} tcp dport 53 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
        }
      '';
    })
  ];
}