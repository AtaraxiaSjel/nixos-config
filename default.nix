# This is AlukardBF's configuration file.
# Thanks for original config - balsoft.
# https://github.com/AlukardBF/nixos-config


device:
{ config, pkgs, lib, ... }:
let sources = import ./nix/sources.nix;
in {
  imports = [
    "${./hardware-configuration}/${device}.nix"
    "${sources.home-manager}/nixos"
    (import ./modules device)
  ];

  inherit device;

  system.stateVersion = "19.03";
}
