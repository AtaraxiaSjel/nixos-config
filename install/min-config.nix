{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "changeme";
    firewall.enable = false;
    networkmanager.enable = false;
    wireless = {
      enable = false;
      userControlled.enable = true;
      networks.Alukard_5GHz = {
        pskRaw = "feee27000fb0d7118d498d4d867416d04d1d9a1a7b5dbdbd888060bbde816fe4";
        priority = 1;
      };
    };
  };

  programs.gnupg = {
    agent.enable = true;
    package = pkgs.gnupg;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    useSandbox = true;
    autoOptimiseStore = true;
    optimise.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    package = pkgs.nixFlakes;
  };

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "Europe/Volgograd";

  environment.systemPackages = with pkgs; [ git ];

  users.mutableUsers = false;
  users.users.alukard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
    hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
  };

  system.stateVersion = "20.03";

}
