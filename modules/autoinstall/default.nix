{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.autoinstall;
  # partitionsAttrs = {
  #   bootPartition = mkOption {
  #     type = types.str;
  #     default = "";
  #     description = "Boot partition";
  #   };
  #   rootPartition = mkOption {
  #     type = types.str;
  #     default = "";
  #     description = "Root partition";
  #   };
  #   swapPartition = mkOption {
  #     type = types.nullOr types.str;
  #     default = "";
  #     description = "Swap partition";
  #   };
  # };
in{
  options = {
    autoinstall = {
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
      hostname = mkOption {
        type = types.str;
        default = "";
        description = "The hostname the system will be known as";
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
          default = "/home/${cfg.mainuser}";
          description = "Path to home user folder relative to persistRoot";
        };
      };
      # rootDevices = mkOption {
      #   type = types.listOf types.str;
      #   default = "/dev/sda";
      #   description = "the root block device that justdoit will nuke from orbit and force nixos onto";
      # };
      # bootSize = mkOption {
      #   type = types.str;
      #   default = "512MiB";
      #   description = "/boot size";
      # };
      # swapSize = mkOption {
      #   type = types.str;
      #   default = "2GiB";
      #   description = "swap size";
      # };
      # osSize = mkOption {
      #   type = types.str;
      #   default = "10GiB";
      #   description = "size of / partition/whatever basically";
      # };
      # wipe = mkOption {
      #   type = types.bool;
      #   default = false;
      #   description = "run wipefs on devices prior to install";
      # };
      # zero = mkOption {
      #   type = types.bool;
      #   default = false;
      #   description = "zero out devices prior to install (time consuming)";
      # };
      # dedicatedBoot = mkOption {
      #   type = types.str;
      #   default = "";
      #   description = "If there should be a dedicated /boot device fill this in with the device name.";
      # };
      # # Needs a lot more testing somehow, vm's?
      # flavor = mkOption {
      #   type = types.enum [ "single" "zfs" "lvm" ];
      #   default = "zfs";
      #   description = "Specify the disk layout type, single = no zfs mirroring or lvm mirroring";
      # };
    };
  };
  config = {
    assertions = [{
      assertion = cfg.flakesPath != "";
      message = "flakesPath can't be empty";
    } {
      assertion = cfg.hostname != "";
      message = "hostname can't be empty";
    } {
      assertion = !(cfg.encryption.enable && cfg.encryption.passwordFile == "");
      message = "If you use encryption, you need to set path to password file";
    }];

    systemd.services."autoinstall-${cfg.hostname}" = {
      description = "NixOS Autoinstall";
      # wantedBy = [ "multi-user.target" ];
      # after = [ "network.target" "polkit.service" ];
      path = with pkgs; [
        "/run/current-system/sw/"
        "/usr/bin/"
        "${systemd}/bin/"
        "${git}/bin"
      ];
      script = with pkgs; (builtins.readFile ./autoinstall.sh);
      environment = config.nix.envVars // rec {
        inherit (config.environment.sessionVariables) NIX_PATH;
        autoReboot = boolToString cfg.autoReboot;
        entireDisk = boolToString cfg.partitioning.useEntireDisk;
        nullifyDisk = boolToString cfg.partitioning.nullifyDisk;
        disk = cfg.partitioning.disk or "0";
        bootPartition = cfg.partitioning.partitions.bootPartition or "0";
        rootPartition = cfg.partitioning.partitions.rootPartition or "0";
        swapPartition = cfg.partitioning.partitions.swapPartition or "0";
        debug = boolToString cfg.debug;
        hostname = cfg.hostname;
        flakesPath = cfg.flakesPath;
        mainUser = cfg.mainuser;
        useSwap = boolToString cfg.swapPartition.enable;
        useEncryption = boolToString cfg.encryption.enable;
        efiSize = cfg.efiSize;
        bootSize = cfg.bootSize;
        rootSize = cfg.rootSize;
        swapSize = cfg.swapPartition.size or "0";
        argonIterTime = cfg.encryption.argonIterTime;
        cryptrootName = cfg.encryption.cryptBoot;
        cryptbootName = cfg.encryption.cryptRoot;
        passwordFile = cfg.encryption.passwordFile;
        zfsAshift = toString cfg.zfsOpts.ashift;
        bootPoolReservation = cfg.zfsOpts.bootPoolReservation;
        rootPoolReservation = cfg.zfsOpts.rootPoolReservation;
        usePersistModule = boolToString cfg.persist.enable;
        persistRoot = cfg.persist.persistRoot;
        persistHome = cfg.persist.persistHome;

        HOME = "/root";
        # LIBSH = "${./lib.sh}:${../../static/src/lib.sh}";
      };
      serviceConfig = { Type = "oneshot"; };
    };
  };
}