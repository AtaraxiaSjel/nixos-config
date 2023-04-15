{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ivpn;
in {
  options.services.ivpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        This option enables iVPN daemon.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];

    environment.systemPackages = with pkgs; [ ivpn ivpn-service ];

    # iVPN writes to /etc/iproute2/rt_tables
    networking.iproute2.enable = true;
    networking.firewall.checkReversePath = "loose";

    systemd.services.ivpn-service = {
      description = "iVPN daemon";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [
        "network-online.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ];
      path = [
        # Needed for mount
        "/run/wrappers"
      ];
      startLimitBurst = 5;
      startLimitIntervalSec = 20;
      serviceConfig = {
        ExecStart = "${pkgs.ivpn-service}/bin/ivpn-service --logging";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}