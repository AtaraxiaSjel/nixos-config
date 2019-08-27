{ config, pkgs, lib, ... }:
let
  cfg = config.secrets.wireguard.${config.device};
in {
  # Enable wireguard
  networking.wg-quick.interfaces = lib.mkIf cfg.enable {
    wg0 = {
      address = [ cfg.address ];
      dns = [ "10.192.122.1" ];
      # TODO change to privateKeyFile
      privateKey = cfg.privateKey;
      peers = [
        {
          allowedIPs = [ "0.0.0.0/0" ];
          publicKey  = "AgtgtS3InfOv4UQ+2MNAEMKFqZGhYXNOFmfMdKXIpng=";
          endpoint   = "51.38.98.116:51820";
        }
      ];
    };
  };
  # Enable killswitch
  networking.nftables = lib.mkIf cfg.enable {
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