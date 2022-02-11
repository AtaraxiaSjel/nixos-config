{ inputs, lib, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.container
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "intel";
      clock = 2300;
      cores = 2;
    };
    drive = {
      type = "hdd";
      speed = 100;
      size = 10;
    };
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 1;
  };
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.wireguard.enable = false;
  deviceSpecific.isServer = lib.mkForce true;

  systemd.suppressedSystemUnits = [
    "sys-kernel-debug.mount"
  ];
}
