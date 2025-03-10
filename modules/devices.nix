{ lib, config, ... }:
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
          (builtins.match ".*Laptop" config.networking.hostName) != null;
      };
      isVM = mkOption {
        type = bool;
        default =
          (builtins.match ".*VM" config.networking.hostName) != null;
      };
      isServer = mkOption {
        type = bool;
        default =
          (builtins.match ".*(Cloud|Server)" config.networking.hostName) != null;
      };
      isContainer = mkOption {
        type = bool;
        default =
          (builtins.match ".*(CT|Container)" config.networking.hostName) != null;
      };
      isISO = mkOption {
        type = bool;
        default =
          (builtins.match ".*ISO" config.networking.hostName) != null;
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
      vpn = {
        mullvad.enable = mkOption {
          type = bool;
          default = false;
        };
        ivpn.enable = mkOption {
          type = bool;
          default = false;
        };
        tailscale.enable = mkOption {
          type = bool;
          default = false;
        };
        sing-box.enable = mkOption {
          type = bool;
          default = false;
        };
        sing-box.config = mkOption {
          type = str;
          default = "";
        };
        wireguard = {
          enable = mkOption {
            type = bool;
            default = false;
          };
          autostart = mkOption {
            type = bool;
            default = false;
          };
          port = mkOption {
            type = int;
            default = 51820;
          };
          endpoint = mkOption {
            type = str;
            default = "";
          };
          address = mkOption {
            type = listOf str;
            default = [];
          };
          allowedIPs = mkOption {
            type = listOf str;
            default = [];
          };
          dns = mkOption {
            type = listOf str;
            default = [];
          };
          gateway = {
            ipv4 = mkOption {
              type = nullOr str;
              default = null;
            };
            ipv6 = mkOption {
              type = nullOr str;
              default = null;
            };
          };
          keys = {
            public = mkOption {
              type = nullOr str;
              default = null;
            };
            presharedFile = mkOption {
              type = nullOr path;
              default = null;
            };
            privateFile = mkOption {
              type = nullOr path;
              default = null;
            };
          };
        };
      };
    };
  };
}
