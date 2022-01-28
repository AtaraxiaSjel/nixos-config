{ inputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.server
  ];

  deviceSpecific.devInfo = {
    cpu = {
      arch = "aarch64";
      vendor = "broadcom";
      clock = 2800;
      cores = 4;
    };
    drive = {
      type = "ssd";
      speed = 1000;
      size = 150;
    };
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 24;
  };
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;

  boot.cleanTmpDir = true;
  # networking.hostName = lib.mkForce "Oracle-Cloud";
}
