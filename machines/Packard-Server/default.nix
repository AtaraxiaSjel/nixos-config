{ inputs, lib, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.server

    hardware
    light
    mullvad
    services
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "intel";
      clock = 2300;
      cores = 4;
    };
    drive = {
      type = "hdd";
      speed = 100;
      size = 500;
    };
    gpu = {
      vendor = "intel";
    };
    bigScreen = false;
    ram = 6;
  };
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = true;
  deviceSpecific.isLaptop = lib.mkForce true;

  boot.cleanTmpDir = true;
  boot.loader = {
    timeout = lib.mkForce 4;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
