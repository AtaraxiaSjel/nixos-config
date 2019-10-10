{ config, pkgs, lib, ... }:
let
  cfg = config.secrets.wireguard.${config.device};
in {
  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
    environment.systemPackages = [ pkgs.wireguard pkgs.wireguard-tools ];
    networking.firewall.checkReversePath = false;

    systemd.services."wg-quick-wg0" = {
      description = "wg-quick WireGuard Tunnel - wg0";
      requires = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.DEVICE = "wg0";
      path = [ pkgs.kmod pkgs.wireguard-tools ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        ${lib.strings.optionalString (!config.boot.isContainer) "modprobe wireguard"}
        wg-quick up /root/wg0.conf
      '';

      postStart = lib.mkIf cfg.killswitch ''
        ${pkgs.iptables}/bin/iptables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ${pkgs.iptables}/bin/iptables -I OUTPUT -s 192.168.0.0/24 -j ACCEPT && ${pkgs.iptables}/bin/ip6tables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
      '';

      preStop = ''
        ${lib.strings.optionalString (cfg.killswitch) "${pkgs.iptables}/bin/iptables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ${pkgs.iptables}/bin/iptables -D OUTPUT -s 192.168.0.0/24 && ${pkgs.iptables}/bin/ip6tables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"}
        wg-quick down /root/wg0.conf
      '';
    };
  };
}