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
  deviceSpecific.vpn.ivpn.enable = true;

  boot.blacklistedKernelModules = [
    "psmouse"
  ];

  services.fwupd.enable = true;

  # systemd.services.unbind-usb2 = {
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.coreutils}/bin/echo 'usb2' | ${pkgs.coreutils}/bin/tee /sys/bus/usb/drivers/usb/unbind";
  #     Type = "oneshot";
  #   };
  # };

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