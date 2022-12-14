{ pkgs, lib, config, ... }:
let
  vpn = config.deviceSpecific.wireguard;
in {
  config = lib.mkIf vpn.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.enableExcludeWrapper = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
    startupApplications = [ "${pkgs.mullvad-vpn}/share/mullvad/mullvad-gui" ];

    persist.state.homeDirectories = [
      ".config/Mullvad VPN"
    ];
  };
}