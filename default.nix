{ config, pkgs, lib, inputs, name, ... }:
rec {
  device = name;

  imports = [
    (./hardware-configuration + "/${name}.nix")
    (import inputs.base16.hmModule)
    (import ./modules device)
  ];

  home-manager.users.alukard.home.stateVersion = "20.09";

  system.stateVersion = "20.09";
}
