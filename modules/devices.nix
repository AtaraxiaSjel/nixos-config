{ pkgs, lib, config, ... }:
with lib;
with types; {
  options = {
    device = mkOption { type = str; };
    deviceSpecific = {
      devInfo = {
        cpu = {
          arch = mkOption { type = enum [ "x86_64" "aarch64" ]; };
          vendor = mkOption { type = enum [ "amd" "intel" "broadcom" ]; };
          clock = mkOption { type = int; };
          cores = mkOption { type = int; };
        };
        drive = {
          type = mkOption { type = enum [ "hdd" "ssd" ]; };
          speed = mkOption { type = int; };
          size = mkOption { type = int; };
        };
        gpu = {
          vendor = mkOption { type = enum [ "amd" "nvidia" "intel" "vm" ]; };
        };
        ram = mkOption { type = int; };
        legacy = mkOption { type = bool; default = false; };
        bigScreen = mkOption {
          type = bool;
          default = true;
        };
      };
      isLaptop = mkOption {
        type = bool;
        default =
          !isNull (builtins.match ".*Laptop" config.networking.hostName);
      };
      isVM = mkOption {
        type = bool;
        default =
          !isNull (builtins.match ".*VM" config.networking.hostName);
      };
      isHost = mkOption {
        type = bool;
        default = false;
      };
      isShared = mkOption {
        type = bool;
        default = false;
      };
      isGaming = mkOption {
        type = bool;
        default = false;
      };
      enableVirtualisation = mkOption {
        type = bool;
        default = config.deviceSpecific.isHost;
      };
      isSSD = mkOption {
        type = bool;
        default = config.deviceSpecific.devInfo.drive.type == "ssd";
      };
    };
  };
}

# { pkgs, lib, config, ... }:
# with lib;
# with types; {
#   options = {
#     device = mkOption { type = strMatching "[A-z|0-9]*-(Laptop|Workstation|VM)"; };
#     devices = mkOption { type = attrs; };
#     deviceSpecific = mkOption { type = attrs; };
#   };
#   config = {
#     deviceSpecific = let
#       device = config.device;
#       devInfo = config.devices.${config.device};
#     in rec {
#       isLaptop = (!isNull (builtins.match ".*Laptop" device));
#       isVM = (!isNull (builtins.match ".*VM" device));
#       isHost = (device == "AMD-Workstation");
#       isShared = devInfo.isShared;
#       isSSD = devInfo.drive.type == "ssd";
#       smallScreen = (device == "Dell-Laptop");
#       cpu = devInfo.cpu.vendor;
#       gpu = devInfo.gpu;
#       ram = devInfo.ram;
#       enableVirtualisation = devInfo.enableVirtualisation;
#       isGaming = devInfo.gaming;
#     };

#     devices = {
#       AMD-Workstation = {
#         cpu = {
#           vendor = "amd";
#           clock = 3700;
#           threads = 12;
#         };
#         drive = {
#           type = "ssd";
#           size = 250;
#         };
#         gpu = "amd";
#         ram = 16;
#         isShared = false;
#         enableVirtualisation = true;
#         gaming = true;
#       };
#       Dell-Laptop = {
#         cpu = {
#           vendor = "intel";
#           clock = 1600;
#           threads = 8;
#         };
#         drive = {
#           type = "ssd";
#           size = 250;
#         };
#         gpu = "intel";
#         ram = 16;
#         isShared = false;
#         enableVirtualisation = true;
#         gaming = true;
#       };
#       NixOS-VM = {
#         cpu = {
#           vendor = "amd";
#           clock = 3700;
#           threads = 4;
#         };
#         drive = {
#           type = "ssd";
#           size = 20;
#         };
#         gpu = "virtualbox";
#         ram = 4;
#         isShared = false;
#         enableVirtualisation = false;
#         gaming = false;
#       };
#     };
#   };
# }
