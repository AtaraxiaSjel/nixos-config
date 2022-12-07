{ config, pkgs, lib, ... }:
let
  tor-browser = pkgs.writeShellScriptBin "tor-browser" ''
    mullvad-exclude ${pkgs.tor-browser-bundle-bin}/bin/tor-browser
  '';
in {
  home-manager.users.alukard.home.packages = if config.deviceSpecific.wireguard.enable then [
    tor-browser
  ] else [
    pkgs.tor-browser-bundle-bin
  ];
}