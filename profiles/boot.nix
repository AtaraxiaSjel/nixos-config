{ lib, pkgs, config, ... }: {
  boot = {
    loader = {
      timeout = lib.mkForce 4;
      systemd-boot.enable = pkgs.system == "x86_64-linux";
    };

    kernelParams = [ "quiet" "scsi_mod.use_blk_mq=1" "modeset" "nofb" ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "pti=off"
        "spectre_v2=off"
      ];

    kernelPackages = pkgs.linuxPackages_zen;

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
