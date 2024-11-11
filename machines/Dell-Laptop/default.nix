{ inputs, config, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    customRoles.desktop

    customProfiles.bluetooth
  ];

  deviceSpecific.devInfo = {
    cpu.vendor = "intel";
    drive.type = "ssd";
    gpu.vendor = "intel";
    ram = 16;
    fileSystem = "zfs";
  };
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.vpn.tailscale.enable = true;
  deviceSpecific.vpn.sing-box.enable = true;
  deviceSpecific.vpn.sing-box.config = "dell-singbox";

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

  persist.state.homeDirectories = [ ".config/Moonlight Game Streaming Project" ];
  home-manager.users.${config.mainuser} = {
    home.packages = [
      pkgs.moonlight-qt
    ];

    home.stateVersion = "24.05";
  };
  system.stateVersion = "23.05";
}
