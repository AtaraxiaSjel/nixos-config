{ inputs, config, pkgs, ... }: {
  imports = with inputs.self.nixosModules; [
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
  deviceSpecific.wireguard.enable = true;

  boot.blacklistedKernelModules = [
    "psmouse"
  ];

  services.acpid.handlers = {
    headphone-plugged = {
      action = ''
        ${pkgs.sudo}/bin/sudo -u alukard -H XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.pulseaudio}/bin/pactl set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-headphones
        ${pkgs.sudo}/bin/sudo -u alukard -H XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.pulseaudio}/bin/pactl set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-headphones
      '';
      event = "jack/headphone HEADPHONE plug";
    };
    headphone-unplugged = {
      action = ''
        ${pkgs.sudo}/bin/sudo -u alukard -H XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.pulseaudio}/bin/pactl set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-speaker
      '';
      event = "jack/headphone HEADPHONE unplug";
    };
  };

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
}
