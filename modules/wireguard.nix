{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.secrets.wireguard.${config.device};
in {
  config = mkIf cfg.enable {
    boot.extraModulePackages = optional (versionOlder kernel.kernel.version "5.6") kernel.wireguard;
    environment.systemPackages = [ pkgs.wireguard-tools ];
    networking.firewall.checkReversePath = false;

    systemd.services."wg-quick-wg0" = {
      description = "wg-quick WireGuard Tunnel - wg0";
      requires = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.DEVICE = "wg0";
      path = [ pkgs.kmod pkgs.wireguard-tools pkgs.iptables pkgs.iproute ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        ${strings.optionalString (!config.boot.isContainer) "modprobe wireguard"}
        wg-quick up /root/wg0.conf
      '';

      postStart = mkIf cfg.killswitch ''
        iptables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT  && ip6tables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
        # Allow IPv4 private ip addresses
        iptables -I OUTPUT -s 192.168.0.0/16 -j ACCEPT && iptables -I OUTPUT -s 172.16.0.0/12 -j ACCEPT
      '';

      preStop = ''
        ${strings.optionalString (cfg.killswitch) "iptables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"}
        # Delete rule thats allow IPv4 private ip addresses
        ${strings.optionalString (cfg.killswitch) "iptables -D OUTPUT -s 192.168.0.0/16 && iptables -D OUTPUT -s 172.16.0.0/12"}
        wg-quick down /root/wg0.conf
      '';

      postStop = ''
        ip link delete wg0
      '';
    };
  };
}