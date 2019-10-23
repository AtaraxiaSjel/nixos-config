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
      path = [ pkgs.kmod pkgs.wireguard-tools pkgs.iptables pkgs.iproute ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        ${lib.strings.optionalString (!config.boot.isContainer) "modprobe wireguard"}
        wg-quick up /root/wg0.conf
      '';

      postStart = lib.mkIf cfg.killswitch ''
        iptables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT  && ip6tables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && iptables -I OUTPUT -s 192.168.0.0/24 -j ACCEPT
        ${lib.strings.optionalString (config.virtualisation.docker.enable) "iptables -I OUTPUT -s 172.17.0.0/16 -j ACCEPT"}
      '';

      preStop = ''
        ${lib.strings.optionalString (cfg.killswitch) "iptables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && iptables -D OUTPUT -s 192.168.0.0/24"}
        ${lib.strings.optionalString (cfg.killswitch && config.virtualisation.docker.enable) "iptables -D OUTPUT -s 172.17.0.0/16"}
        wg-quick down /root/wg0.conf
      '';

      postStop = ''
        ip link delete wg0
      '';
    };

    # systemd.services."iptables-docker" = lib.mkIf (config.virtualisation.docker.enable) {
    #   description = "Configure iptables to work with docker";
    #   wantedBy = [ "multi-user.target" ];
    #   path = [ pkgs.iptables pkgs.iproute pkgs.gnugrep pkgs.gnused ];

    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #   };

    #   script = ''
    #     iptables -A FORWARD -i docker0 -o $(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//") -j ACCEPT
    #     iptables -A FORWARD -i $(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//") -o docker0 -j ACCEPT
    #   '';
    # };

    # virtualisation.docker.extraOptions = lib.mkIf (config.virtualisation.docker.enable)
    #   "--iptables=false";
  };
}