{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems = {
    "/" = {
      options = [ "noatime" "ssd" "discard" "compress=zstd" ];
    };
  };

  swapDevices = [
    { label = "swap"; }
  ];

  networking = {
    hostName = "nixos";
    firewall.enable = false;
    networkmanager.enable = false;
    wireless.enable = true;
    wireless.userControlled.enable = true;
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Volgograd";

  environment.systemPackages = with pkgs; [
    wget vim git
  ];

  users.users.alukard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "19.03";

}
