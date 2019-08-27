{ pkgs, lib, config, ... }:
with lib;
with types; {
  options = {
    device = mkOption { type = strMatching "[A-z]*-[A-z]*"; };
    devices = mkOption { type = attrs; };
    deviceSpecific = mkOption { type = attrs; };
  };
  config = {
    deviceSpecific = let
      device = config.device;
      devInfo = config.devices.${config.device};
    in rec {
      isLaptop = (!isNull (builtins.match ".*Laptop" device));
      # smallScreen = (device == "Prestigio-Laptop");
      isShared = devInfo.isShared;
      cpu = devInfo.cpu.vendor;
      isSSD = devInfo.drive.type == "ssd";
      hostName = if !isNull devInfo.hostName then
        devInfo.hostName
      else
        device;
      # goodMachine = devInfo.cpu.clock * devInfo.cpu.cores >= 4000
      # && devInfo.drive.size >= 100 && devInfo.ram
      # >= 8; # Whether machine is powerful enough for heavy stuff
      isHost = (device == "AMD-Workstation");
    };

    devices = {
      AMD-Workstation = {
        cpu = {
          vendor = "amd";
          clock = 3800;
          cores = 6;
        };
        drive = {
          type = "ssd";
          size = 250;
        };
        ram = 16;
        isShared = false;
        hostName = "ataraxia-pc";
      };
      PackardBell-Laptop = {
        cpu = {
          vendor = "intel";
          clock = 2500;
          cores = 2;
        };
        drive = {
          type = "hdd";
          size = 500;
        };
        ram = 6;
        isShared = true;
        hostName = null;
      };
      NixOS-VM = {
        cpu = {
          vendor = "amd";
          clock = 3600;
          cores = 2;
        };
        drive = {
          type = "ssd";
          size = 12;
        };
        ram = 4;
        isShared = false;
        hostName = null;
      };
    };
  };
}
