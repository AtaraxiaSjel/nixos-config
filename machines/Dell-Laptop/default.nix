{ inputs, config, ... }: {
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
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;

  boot.blacklistedKernelModules = [
    "psmouse"
  ];

  services.fwupd.enable = true;

  fileSystems = {
    "/media/local/files" = {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/506c04f2-ecb1-4747-843a-576163828373";
      options = [
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbgrp.gid}"
        "dmask=027"
        "fmask=137"
        "rw"
      ];
    };
    "/media/local/sys" = {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/bf5cdb93-fce3-4b02-8ba5-e43483a3a061";
      options = [
        "nofail"
        "uid=${toString config.users.users.alukard.uid}"
        "gid=${toString config.users.groups.smbgrp.gid}"
        "dmask=027"
        "fmask=137"
        "ro"
      ];
    };
  };

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
