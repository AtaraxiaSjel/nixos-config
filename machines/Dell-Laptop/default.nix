{ inputs, ... }: {
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    inputs.self.nixosProfiles.desktop
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "intel";
      clock = 3600;
      cores = 4;
    };
    drive = {
      type = "ssd";
      speed = 3000;
      size = 250;
    };
    gpu = {
      vendor = "intel";
    };
    bigScreen = false;
    ram = 16;
  };
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = true;
  deviceSpecific.enableVirtualisation = false;

  boot.blacklistedKernelModules = [
    "psmouse"
  ];

  services.fwupd.enable = true;

  # systemd.services.unbind-usb2 = {
  #   script = ''
  #     echo 'usb2' | tee /sys/bus/usb/drivers/usb/unbind
  #   '';
  #   wantedBy = [ "multi-user.target" ];
  # };

  # boot.kernelParams = lib.mkIf (device == "Dell-Laptop") [
  #   "mem_sleep_default=deep"
  # ];
}
