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
          vendor = mkOption { type = enum [ "amd" "nvidia" "intel" "vm" "other" ]; };
        };
        fileSystem = mkOption { type = enum [ "btrfs" "zfs" "other" ]; default = "other"; };
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
      isServer = mkOption {
        type = bool;
        default =
          !isNull (builtins.match ".*(Cloud|Server)" config.networking.hostName);
      };
      isContainer = mkOption {
        type = bool;
        default =
          !isNull (builtins.match ".*(CT|Container)" config.networking.hostName);
      };
      isISO = mkOption {
        type = bool;
        default =
          !isNull (builtins.match ".*ISO" config.networking.hostName);
      };
      isDesktop = mkOption {
        type = bool;
        default = with config.deviceSpecific; (!isLaptop && !isVM && !isISO);
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
      wireguard = {
        enable = mkOption {
          type = bool;
          default = false;
        };
        killswitch = mkOption {
          type = bool;
          default = true;
        };
      };
    };
  };
}
