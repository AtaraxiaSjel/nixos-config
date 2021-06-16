{ inputs, ... }: {
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    inputs.self.nixosProfiles.desktop
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 4;
    };
    drive = {
      type = "ssd";
      speed = 1000;
      size = 30;
    };
    gpu = {
      vendor = "vm";
    };
    bigScreen = true;
    ram = 4;
  };
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
}
