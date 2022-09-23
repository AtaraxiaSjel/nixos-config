{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.workstation
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 6;
    };
    drive = {
      type = "ssd";
      speed = 6000;
      size = 1000;
    };
    gpu = {
      vendor = "amd";
    };
    bigScreen = true;
    ram = 16;
  };
  deviceSpecific.isHost = true;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = true;
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.wireguard.enable = true;

  hardware.video.hidpi.enable = lib.mkForce false;
  hardware.firmware = [ pkgs.rtl8761b-firmware ];

  home-manager.users.alukard.home.packages = lib.mkIf config.deviceSpecific.enableVirtualisation [
    inputs.nixos-generators.packages.${pkgs.system}.nixos-generators
    inputs.miniguest.packages.${pkgs.system}.miniguest
  ];
}
