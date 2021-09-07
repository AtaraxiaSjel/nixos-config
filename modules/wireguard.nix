{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.deviceSpecific.wireguard;
  kernel = config.boot.kernelPackages;
in {
  config = mkIf cfg.enable {
    boot.extraModulePackages = optional (versionOlder kernel.kernel.version "5.6") kernel.wireguard;
    networking.firewall.checkReversePath = "loose";
    environment.systemPackages = [ pkgs.wireguard-tools pkgs.mullvad-vpn ];
    services.mullvad-vpn.enable = true;
    startupApplications = [ "${pkgs.mullvad-vpn}/share/mullvad/mullvad-gui" ];
  };
}