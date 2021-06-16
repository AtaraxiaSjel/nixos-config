{ lib, pkgs, config, ... }: {
  boot = {
    loader = {
      systemd-boot.enable = lib.mkIf (pkgs.system == "x86_64-linux") true;
      # efi.canTouchEfiVariables = true;
    };

    # kernelPackages = if config.deviceSpecific.isVM then
    #   pkgs.linuxPackages
    # else
    #   # pkgs.linuxPackages_latest;
    #   pkgs.linuxPackages; # FIXME
    kernelPackages = pkgs.linuxPackages_latest;

    supportedFilesystems = [ "ntfs" ];

    initrd.kernelModules = if config.deviceSpecific.devInfo.gpu.vendor == "intel" then
      [ "i915" ]
    else
      [ ];

    extraModprobeConfig = lib.mkIf (config.device == "AMD-Workstation") ''
      options snd slots=snd_virtuoso,snd_usb_audio
    '';

    consoleLogLevel = 3;
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
  };
}
