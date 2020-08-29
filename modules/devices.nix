{ pkgs, lib, config, ... }:
with lib;
with types; {
  options = {
    device = mkOption { type = strMatching "[A-z|0-9]*-(Laptop|Workstation|VM)"; };
    devices = mkOption { type = attrs; };
    deviceSpecific = mkOption { type = attrs; };
  };
  config = {
    deviceSpecific = let
      device = config.device;
      devInfo = config.devices.${config.device};
    in rec {
      isLaptop = (!isNull (builtins.match ".*Laptop" device));
      isVM = (!isNull (builtins.match ".*VM" device));
      isHost = (device == "AMD-Workstation");
      isShared = devInfo.isShared;
      isSSD = devInfo.drive.type == "ssd";
      smallScreen = (device == "Dell-Laptop");
      cpu = devInfo.cpu.vendor;
      video = devInfo.video;
      enableVirtualisation = devInfo.enableVirtualisation;
      isGaming = devInfo.gaming;
    };

    devices = {
      AMD-Workstation = {
        cpu = {
          vendor = "amd";
          clock = 3700;
          threads = 12;
        };
        drive = {
          type = "ssd";
          size = 250;
        };
        video = "amd";
        ram = 16;
        isShared = false;
        enableVirtualisation = true;
        gaming = true;
      };
      Dell-Laptop = {
        cpu = {
          vendor = "intel";
          clock = 1600;
          threads = 8;
        };
        drive = {
          type = "ssd";
          size = 250;
        };
        video = "intel";
        ram = 16;
        isShared = false;
        enableVirtualisation = false;
        gaming = true;
      };
      NixOS-VM = {
        cpu = {
          vendor = "amd";
          clock = 3700;
          threads = 4;
        };
        drive = {
          type = "ssd";
          size = 20;
        };
        video = "virtualbox";
        ram = 4;
        isShared = false;
        enableVirtualisation = false;
        gaming = false;
      };
    };
  };
}
