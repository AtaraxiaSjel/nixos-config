{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.autoinstall;

  autoinstallOptions = { name, ... }: {
    options = rec {
      autoReboot = mkOption {
        type = types.bool;
        default = false;
        description = "Auto reboot after install complete successufuly";
      };
      partitioning = {
        useEntireDisk = mkOption {
          type = types.bool;
          default = true;
          description = "Wipe entire disk and write new partition table";
        };
        nullifyDisk = mkOption {
          type = types.bool;
          default = false;
          description = "Nullify entire disk. Very slow!";
        };
        disk = mkOption {
          type = types.str;
          default = "";
          description = "Path to the disk to wipe";
        };
        # partitions = mkOption {
        #   type = types.nullOr attrsOf partitionsAttrs;
        #   default = null;
        #   description = "If not wipe entire disk";
        # };
      };
      debug = mkOption {
        type = types.bool;
        default = false;
        description = "If we should exit before installing or not to let debugging occur";
      };
      mainuser = mkOption {
        type = types.str;
        default = "alukard";
        description = "Name of the main user (used for creation of home folder)";
      };
      flakesPath = mkOption {
        type = types.str;
        default = "";
        description = "Path to config folder with flakes";
      };
      efiSize = mkOption {
        type = types.str;
        default = "512MiB";
        description = "Size of EFI partition";
      };
      bootSize = mkOption {
        type = types.str;
        default = "4GiB";
        description = "Size of boot partition";
      };
      rootSize = mkOption {
        type = types.str;
        default = "0";
        description = "Size of root partition. If using 0, expand root partition to entire free space on disk";
      };
      swapPartition = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Use swap partition";
        };
        size = mkOption {
          type = types.str;
          default = "2GiB";
          description = "Size of swap partition";
        };
      };
      encryption = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Use luks full-disk encryption";
        };
        argonIterTime = mkOption {
          type = types.str;
          default = "5000";
          description = "iter-time for argon2 in ms";
        };
        cryptBoot = mkOption {
          type = types.str;
          default = "cryptboot";
          description = "Name of luks boot device";
        };
        cryptRoot = mkOption {
          type = types.str;
          default = "cryptroot";
          description = "Name of luks root device";
        };
        passwordFile = mkOption {
          type = types.str;
          default = "";
          description = "Path to file that contains password that pass to luksFormat";
        };
      };
      zfsOpts = {
        ashift = mkOption {
          type = types.int;
          default = 13;
          description = "ashift passed to zfs pool creation";
        };
        bootPoolReservation = mkOption {
          type = types.str;
          default = "0";
          description = "Reserve some space on boot pool";
        };
        rootPoolReservation = mkOption {
          type = types.str;
          default = "0";
          description = "Reserve some space on root pool";
        };
      };
      persist = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Use persist module";
        };
        persistRoot = mkOption {
          type = types.str;
          default = "/persist";
          description = "Path to persist mount point";
        };
        persistHome = mkOption {
          type = types.str;
          default = "/home/${cfg.${name}.mainuser}";
          description = "Path to home user folder relative to persistRoot";
        };
      };
      oldUefi = mkOption {
        type = types.bool;
        default = false;
        description = "Copy bootx64.efi to windows efi location (EFI/Microsoft/Boot/bootmgr.efi)";
      };
    };
  };

  mkService = name: opt: {
    description = "Autoinstall NixOS on ${name}";
    # wantedBy = [ "multi-user.target" ];
    # after = [ "network.target" "polkit.service" ];
    path = with pkgs; [
      "/run/current-system/sw/"
      "/usr/bin/"
      "${systemd}/bin/"
      "${git}/bin"
    ];
    script = import ./install.nix {
      inherit lib; inherit opt; hostname = name;
    };
    environment = config.nix.envVars // rec {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    serviceConfig = { Type = "oneshot"; };
  };
in {
  options.autoinstall = mkOption {
    default = {};
    type = types.attrsOf (types.submodule autoinstallOptions);
  };

  config = lib.mkIf (cfg != {}) {
    systemd.services = mapAttrs' (n: v: nameValuePair "autoinstall-${n}" (mkService n v)) cfg;
  };
}