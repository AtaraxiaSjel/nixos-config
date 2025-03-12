{ config, lib, ... }:
let
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
    ;
  cfg = config.ataraxia.filesystems.zfs;
in
{
  options.ataraxia.filesystems.zfs = {
    enable = mkEnableOption "Root on zfs";
    # Zfs clean root
    eraseOnBoot = {
      enable = mkOption {
        type = bool;
        default = config.persist.enable;
        description = "Rollback zfs datasets on boot";
      };
      snapshots = mkOption {
        type = listOf str;
        default = [ ];
        example = [ "rpool/nixos/root@empty" ];
        description = ''
          A list of dataset snapshots to rollback on boot.
        '';
      };
    };
  };

  config =
    let
      script = concatStringsSep "\n" (
        map (x: ''
          ${config.boot.zfs.package}/bin/zfs rollback -r ${x} && echo ">>> rollback ${x} <<<"
        '') cfg.eraseOnBoot.snapshots
      );
    in
    mkIf cfg.enable {
      boot.initrd = mkIf cfg.eraseOnBoot.enable {
        postDeviceCommands = mkIf (!config.boot.initrd.systemd.enable) (mkBefore script);

        systemd.services.rollback = mkIf config.boot.initrd.systemd.enable {
          description = "Rollback zfs datasets to a pristine state on boot";
          wantedBy = [ "initrd.target" ];
          requires = [ "zfs-import-rpool.service" ];
          after = [ "zfs-import-rpool.service" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = script;
        };
      };

      persist.state.files = [
        "/etc/zfs/zpool.cache"
      ];
    };
}
