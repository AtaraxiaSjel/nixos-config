{ pkgs, lib, config, ... }:
let
  vpn = config.deviceSpecific.wireguard;
in {
  config = lib.mkIf vpn.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.enableExcludeWrapper = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
    startupApplications = [ "${pkgs.mullvad-vpn}/share/mullvad/mullvad-gui" ];

    services.tailscale = {
      enable = true;
      #interfaceName = "userspace-networking";
      interfaceName = "tailscale0";
    };
    systemd.services.tailscaled.serviceConfig.ExecStart = lib.mkForce [
      ""
      "${pkgs.mullvad}/bin/mullvad-exclude ${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=\${PORT} $FLAGS"
    ];
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

    persist.state.directories = [ "/var/lib/tailscale" ];
    persist.state.homeDirectories = [ ".config/Mullvad VPN" ];
  };
}