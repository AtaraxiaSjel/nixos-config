{ config, lib, pkgs, ... }: {

  nixpkgs.config = {
    allowUnfree = true;
  };
  nix = {
    useSandbox = true;
    autoOptimiseStore = config.deviceSpecific.isSSD;
    optimise.automatic = true;
  };
  environment.systemPackages = with pkgs; [
    xfce4-14.xfce4-taskmanager
  ];
}