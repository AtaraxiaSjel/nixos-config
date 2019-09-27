{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.networking.mullvad;
in {
  ###### interface

  options = {
    networking.mullvad = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          This option enables mullvad vpn daemon.
        '';
      };
      enableOnBoot = mkOption {
        type = types.bool;
        default = true;
        description = ''
          When enabled mullvad daemon is started on boot.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mullvad-vpn openvpn ];
    boot.kernelModules = [ "tun" ];

    systemd.services.mullvad-daemon = {
      description = "Mullvad VPN daemon";
      wantedBy = optional cfg.enableOnBoot "multi-user.target";
      wants = [ "network.target" ];
      after = [
        "network-online.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ];
      startLimitIntervalSec = 20;
      serviceConfig = {
        ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad-daemon -v --disable-stdout-timestamps";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };

}