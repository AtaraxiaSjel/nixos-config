{ config, lib, pkgs, ... }: {

  nixpkgs.config = {
    allowUnfree = true;
  };
  nix = {
    useSandbox = true;
    autoOptimiseStore = config.deviceSpecific.isSSD;
    optimise.automatic = true;
  };
}