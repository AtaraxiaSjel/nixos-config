{ lib, pkgs, config, ... }: {
  boot = {
    loader = {
      systemd-boot.enable = lib.mkIf (pkgs.system == "x86_64-linux") true;
      # efi.canTouchEfiVariables = true;
    };

    kernelPackages = if config.deviceSpecific.isVM then
      pkgs.linuxPackages
    else
      pkgs.linuxPackages_latest;

    supportedFilesystems = [ "ntfs" ];

    blacklistedKernelModules = lib.mkIf (config.device == "Dell-Laptop") [
      "psmouse"
    ];

    initrd.kernelModules = if config.deviceSpecific.devInfo.gpu.vendor == "intel" then [ "iHD" ] else [ ];

    # kernelParams = lib.mkIf (device == "Dell-Laptop") [
    #   "mem_sleep_default=deep"
    # ];

    extraModprobeConfig = lib.mkIf (config.device == "AMD-Workstation") ''
      options snd slots=snd_virtuoso,snd_usb_audio
    '';

    consoleLogLevel = 3;
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
  };
}
