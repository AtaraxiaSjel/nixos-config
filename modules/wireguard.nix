{ config, pkgs, lib, ... }:
let
  cfg = config.secrets.wireguard.${config.device};
in {
  # Enable wireguard
  networking.wg-quick.interfaces = lib.mkIf cfg.enable {
    wg0 = cfg.interface;
  };
  # Enable killswitch
  environment.systemPackages =
    lib.mkIf (cfg.killswitch.package == "iptables") [
      pkgs.iptables
    ];
  networking.nftables =
    lib.mkIf (cfg.killswitch.package == "nftables") {
    enable = true;
    ruleset = ''
      flush ruleset
      table inet firewall {
          chain input {
              type filter hook input priority 0; policy drop;
              iif "lo" accept
              ct state { established, related } accept
              ct state invalid drop
              ip protocol icmp icmp type echo-request accept
              ip daddr 192.168.0.1/24 accept
              reject
          }
          chain forward {
              type filter hook forward priority 0; policy drop;
          }
          chain output {
              type filter hook output priority 0; policy drop;
              oifname "lo" accept
              oifname "wg0" accept
              oifname "docker0" accept
              oifname "vboxnet0" accept
              oifname "vboxnet1" accept
              udp dport domain drop
              ip daddr 192.168.0.1/24 accept
              udp dport 51820 accept
          }
      }
    '';
  };
}