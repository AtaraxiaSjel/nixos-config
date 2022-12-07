{ pkgs, lib, config, ... }:
let
  vpn = config.deviceSpecific.wireguard;
in {
  config = lib.mkIf vpn.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.enableExcludeWrapper = true;
    home-manager.users.alukard.home.packages = [ pkgs.mullvad-vpn ];
    startupApplications = [ "${pkgs.mullvad-vpn}/share/mullvad/mullvad-gui" ];
  };
}