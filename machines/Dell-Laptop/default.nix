{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    nixosRoles.desktop
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "intel";
      clock = 1600;
      cores = 8;
    };
    drive = {
      type = "ssd";
      speed = 2000;
      size = 250;
    };
    gpu = {
      vendor = "intel";
    };
    bigScreen = false;
    ram = 16;
    fileSystem = "zfs";
  };
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.vpn.tailscale.enable = true;
  secrets.wg-dell.services = [ "wg-quick-wg0.service" ];
  networking.wg-quick.interfaces.wg0.configFile = config.secrets.wg-dell.decrypted;

  boot.blacklistedKernelModules = [
    "psmouse"
  ];

  services.fwupd.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };

  boot.kernelParams = [ "mem_sleep_default=deep" ];

  home-manager.users.${config.mainuser} = {
    home.stateVersion = "23.05";
  };
  system.stateVersion = "23.05";
}