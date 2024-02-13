{ config, lib, pkgs, inputs, ... }:
with lib;
{
  options.backups.postgresql = mkOption {
    description = mdDoc ''
      Periodic backups of postgresql database to create with Rustic.
    '';
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        dbName = mkOption {
          type = types.str;
          default = name;
        };
        proxyAddress = mkOption {
          type = with types; nullOr str;
          default = "http://192.168.0.6:8888";
        };
      };
    }));
    default = { };
  };
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rustic ];
  config = mkIf (config.backups.postgresql != { }) {
    sops.secrets.rustic-postgresql-s3-env.sopsFile = inputs.self.secretsDir + /rustic.yaml;
    sops.secrets.rustic-postgresql-pass.sopsFile = inputs.self.secretsDir + /rustic.yaml;
    sops.secrets.rustic-postgresql-s3-env.owner = "postgres";
    sops.secrets.rustic-postgresql-pass.owner = "postgres";

    services.rustic.backups =
      mapAttrs'
        (name: backup: nameValuePair "postgresql-${name}" ({
          backup = true;
          prune = true;
          initialize = true;
          user = "postgres";
          extraEnvironment.https_proxy = mkIf (backup.proxyAddress != null) backup.proxyAddress;
          environmentFile = config.sops.secrets.rustic-postgresql-s3-env.path;
          pruneOpts = [ "--repack-cacheable-only=false" ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
          };
          # Backup postgresql db and pass it to rustic through stdin
          backupCommandPrefix = "${config.services.postgresql.package}/bin/pg_dump ${backup.dbName} | ${pkgs.zstd}/bin/zstd --rsyncable --stdout - |";
          extraBackupArgs = [ "-" ];
          # Rustic profile yaml
          settings = {
            repository = {
              repository = "opendal:s3";
              password-file = config.sops.secrets.rustic-postgresql-pass.path;
              options = {
                root = backup.dbName;
                bucket = "ataraxia-postgresql-backups";
                region = "eu-central-003";
                endpoint = "https://s3.eu-central-003.backblazeb2.com";
              };
            };
            backup = {
              host = config.device;
              label = backup.dbName;
              ignore-devid = true;
              group-by = "label";
              skip-identical-parent = true;
              stdin-filename = "${backup.dbName}.dump.zst";
            };
            forget = {
              filter-label = [ backup.dbName ];
              group-by = "label";
              prune = true;
              keep-daily = 4;
              keep-weekly = 2;
              keep-monthly = 1;
            };
          };
        })
      ) config.backups.postgresql;
  };
}