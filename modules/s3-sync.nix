{ config, lib, pkgs, utils, ... }:
with lib;
let
  inherit (utils.systemdUtils.unitOptions) unitOption;
in {
  options.backups.rclone-sync = mkOption {
    description = ''
      Sync buckets beetween two storages.
    '';
    type = types.attrsOf (types.submodule ({ ... }: {
      options = {
        rcloneConfigFile = mkOption {
          type = with types; nullOr path;
          default = null;
          description = ''
            Path to the file containing rclone configuration. This file
            must contain configuration for the remotes specified in this backup
            set and also must be readable by root.
          '';
        };
        syncOpts = mkOption {
          type = with types; listOf str;
          default = [ "--checksum" "--fast-list" ];
          description = ''
            A list of options for 'rclone sync'.
          '';
        };
        syncTargets = mkOption {
          type = with types; listOf (submodule {
            options = {
              source = mkOption {
                type = types.str;
                default = "";
                description = "Source to sync.";
              };
              target = mkOption {
                type = types.str;
                default = "";
                description = "Target to sync.";
              };
            };
          });
          default = { };
          description = ''
            List of sync targets.
          '';
        };
        timerConfig = mkOption {
          type = types.attrsOf unitOption;
          default = {
            OnCalendar = "06:15";
            RandomizedDelaySec = "15m";
            Persistent = true;
          };
          description = ''
            When to run the backup. See {manpage}`systemd.timer(5)` for details.
          '';
        };
        proxyAddress = mkOption {
          type = with types; nullOr str;
          default = "http://10.10.10.6:8888";
        };
      };
    }));
    default = { };
  };
  config = mkIf (config.backups.rclone-sync != { }) {
    systemd.services =
      mapAttrs'
        (name: backup: nameValuePair "rclone-sync-${name}" ({
          path = [ pkgs.rclone ];
          restartIfChanged = false;
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          environment = {
            RCLONE_CONFIG = backup.rcloneConfigFile;
            https_proxy = mkIf (backup.proxyAddress != null) backup.proxyAddress;
          };
          script = lib.pipe backup.syncTargets [
            (map (v: "rclone sync ${concatStringsSep " " backup.syncOpts} ${v.source} ${v.target}"))
            (lib.concatStringsSep "\n")
          ];
          serviceConfig = {
            Type = "oneshot";
            RuntimeDirectory = "rclone-sync-${name}";
            CacheDirectory = "rclone-sync-${name}";
            CacheDirectoryMode = "0700";
            PrivateTmp = true;
          };
        })
      ) config.backups.rclone-sync;

    systemd.timers =
      mapAttrs'
        (name: backup: nameValuePair "rclone-sync-${name}" {
          wantedBy = [ "timers.target" ];
          timerConfig = backup.timerConfig;
        })
        config.backups.rclone-sync;
  };
}