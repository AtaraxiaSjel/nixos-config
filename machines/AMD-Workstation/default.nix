{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosProfiles.desktop
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
}
