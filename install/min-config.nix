{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos";
    firewall.enable = false;
    networkmanager.enable = false;
    wireless = {
      enable = true;
      userControlled.enable = true;
      networks.Alukard_5GHz = {
        pskRaw = "feee27000fb0d7118d498d4d867416d04d1d9a1a7b5dbdbd888060bbde816fe4";
        priority = 1;
      };
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  nix = {
    useSandbox = true;
    autoOptimiseStore = true;
    optimise.automatic = true;
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Volgograd";

  environment.systemPackages = with pkgs; [
    wget vim git gnupg
  ];

  users.mutableUsers = false;
  users.users.alukard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
    hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
  };

  system.stateVersion = "20.03";

}
