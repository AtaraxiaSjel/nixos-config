{ config, pkgs, lib, inputs, name, ... }:
rec {
  device = name;

  imports = [
    (./hardware-configuration + "/${name}.nix")
    inputs.home-manager.nixosModules.home-manager
    (import inputs.base16.hmModule)
    (import ./modules device)
  ];

  system.stateVersion = "20.03";
}
