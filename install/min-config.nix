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
      enable = true;
      networks.Alukard_5GHz = {
        pskRaw = "feee27000fb0d7118d498d4d867416d04d1d9a1a7b5dbdbd888060bbde816fe4";
        priority = 1;
      };
      networks.Alukard.pskRaw =
        "5ef5fe07c1f062e4653fce9fe138cc952c20e284ae1ca50babf9089b5cba3a5a";
      networks.AlukardAP = {
        pskRaw = "b8adc07cf1a9c7a7a5946c2645283b27ab91a8af4c065e5f9cde03ed1815811c";
        priority = 2;
      };
      networks.AlukardAP_5GHz = {
        pskRaw = "d1733d7648467a8a9cae9880ef10a2ca934498514b4da13b53f236d7c68b8317";
        priority = 1;
      };
      userControlled.enable = true;
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
    autoOptimiseStore = false;
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

  time.timeZone = "Europe/Moscow";

  environment.systemPackages = with pkgs; [ git ];

  users.mutableUsers = false;
  users.users.alukard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
    hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
  };

  system.stateVersion = "21.05";

}
