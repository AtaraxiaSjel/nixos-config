{ inputs, config, pkgs, ... }: {
  imports = with inputs.self.customModules; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
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
    fileSystem = "btrfs";
  };
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = true;
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.vpn.mullvad.enable = true;

  boot.blacklistedKernelModules = [
    "psmouse"
  ];

  services.fwupd.enable = true;

  systemd.services.unbind-usb2 = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/echo 'usb2' | ${pkgs.coreutils}/bin/tee /sys/bus/usb/drivers/usb/unbind";
      Type = "oneshot";
    };
  };

  # boot.kernelParams = lib.mkIf (device == "Dell-Laptop") [
  #   "mem_sleep_default=deep"
  # ];

  home-manager.users.${config.mainuser}.home.stateVersion = "21.11";
  system.stateVersion = "21.11";
}
