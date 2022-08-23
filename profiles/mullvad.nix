{ pkgs, lib, config, ... }:
let
  vpn = config.deviceSpecific.wireguard;
in {
  config = lib.mkIf vpn.enable {
    services.mullvad-vpn.enable = true;
    home-manager.users.alukard.home.packages = [ pkgs.mullvad-vpn ];
    startupApplications = [ "${pkgs.mullvad-vpn}/share/mullvad/mullvad-gui" ];
    security.wrappers.mullvad-exclude = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.mullvad-vpn}/bin/mullvad-exclude";
    };
  };
}