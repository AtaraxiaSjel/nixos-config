{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) map;
  inherit (lib)
    concatStringsSep
    mkIf
    mkEnableOption
    mkOption
    mkBefore
    ;
  inherit (lib.types)
    bool
    str
    listOf
    submodule
    ;
  cfg = config.ataraxia.filesystems.btrfs;

  eraseVolumesOpts =
    { ... }:
    {
      options = {
        vol = mkOption {
          type = str;
          example = "rootfs";
          description = "Name of submodule to erase";
        };
        blank = mkOption {
          type = str;
          example = "rootfs-blank";
          description = "Name of submodule to clone into `vol`";
        };
      };
    };
in
{
  options.ataraxia.filesystems.btrfs = {
    enable = mkEnableOption "Root on btrfs";
    mountpoints = mkOption {
      type = listOf str;
      default = [ ];
      description = ''
        A list of absolute paths to BTRFS subvolume mountpoints.
        These paths will be automatically filtered out from the directories persisted through
        persist module to prevent conflicts with BTRFS' native mount management. Any matching entries
        in the persistence list will be removed.
      '';
    };
    # Btrfs clean root
    eraseOnBoot = {
      enable = mkOption {
        type = bool;
        default = config.persist.enable;
        description = "Clean btrfs subvolumes on boot";
      };
      eraseVolumes = mkOption {
        type = listOf (submodule eraseVolumesOpts);
        default = [ ];
        example = [
          {
            vol = "rootfs";
            blank = "rootfs-blank";
          }
        ];
        description = ''
          A list of subvolumes to erase on boot.
        '';
      };
      device = mkOption {
        type = str;
        description = "Device on which is btrfs partititon";
      };
      waitForDevice = mkOption {
        type = str;
        description = "Escaped string with name of .device service";
        example = "dev-disk-by\\x2did-ata\\x2dPhison_SATA_SSD_2165.device";
      };
    };
  };

  config =
    let
      script = ''
        mkdir -p /mnt
        mount -t btrfs -o subvol=/ ${cfg.eraseOnBoot.device} /mnt

        ${concatStringsSep "\n" (
          map (x: ''
            btrfs subvolume list -o /mnt/${x.vol} |
            cut -f9 -d' ' |
            while read subvolume; do
              echo "deleting /$subvolume subvolume..."
              btrfs subvolume delete "/mnt/$subvolume"
            done &&

            echo "deleting /${x.vol} subvolume..."
            btrfs subvolume delete /mnt/${x.vol}
            echo "restoring blank ${x.blank} subvolume..."
            btrfs subvolume snapshot /mnt/snapshots/${x.blank} /mnt/${x.vol}
          '') cfg.eraseOnBoot.eraseVolumes
        )}

        umount /mnt
      '';
    in
    mkIf cfg.enable {
      boot.initrd = mkIf cfg.eraseOnBoot.enable {
        postDeviceCommands = mkIf (!config.boot.initrd.systemd.enable) (mkBefore script);

        systemd.services.rollback = mkIf config.boot.initrd.systemd.enable {
          description = "Rollback btrfs root subvolume to a pristine state on boot";
          wantedBy = [ "initrd.target" ];
          requires = [ cfg.eraseOnBoot.waitForDevice ];
          after = [ cfg.eraseOnBoot.waitForDevice ];
          before = [ "sysroot.mount" ];
          path = [
            pkgs.btrfs-progs
            pkgs.coreutils
            pkgs.util-linuxMinimal.mount
          ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = script;
        };
      };
    };
}
