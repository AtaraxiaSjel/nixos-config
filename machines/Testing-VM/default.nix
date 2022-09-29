{ inputs, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 2;
    };
    drive = {
      type = "ssd";
      speed = 2000;
      size = 30;
    };
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 4;
  };
  deviceSpecific.isHost = true;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;

  hardware.video.hidpi.enable = lib.mkForce false;

  boot.kernelPackages = lib.mkForce boot.zfs.package.latestCompatibleLinuxPackages;
}
