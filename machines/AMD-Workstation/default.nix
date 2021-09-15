{ inputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
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

  services.xserver.config = ''
    Section "InputClass"
      Identifier         "C-Media USB Headphone Set"
      MatchUSBID         "0d8c:000c"
      Option             "Ignore" "true"
    EndSection
  '';
}
