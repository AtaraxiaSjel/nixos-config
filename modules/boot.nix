{ lib, pkgs, config, ... }: {
  boot = {
    loader = {
      systemd-boot.enable = lib.mkIf (pkgs.system == "x86_64-linux") true;
      # efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    supportedFilesystems = [ "ntfs" ];

    extraModprobeConfig = lib.mkIf (config.device == "AMD-Workstation") ''
      options snd slots=snd_virtuoso,snd_usb_audio
    '';

    consoleLogLevel = 3;
    kernel.sysctl = {
      "vm.swappiness" = if config.deviceSpecific.isSSD then 1 else 10;
    };
  };
}
