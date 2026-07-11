{
  config,
  lib,
  pkgs,
  ...
}:

let
  tomlFormat = pkgs.formats.toml { };

  cfg = config.services.rustic-new;
  configFiles = lib.mapAttrs (k: v: tomlFormat.generate "rustic-${k}.toml" v) cfg.profiles;

  mkGenericArgs =
    v:
    let
      credArg = lib.optionalString (
        v.credentialsProfile != null
      ) " -P \"$CREDENTIALS_DIRECTORY/rustic-creds\"";
      profileArgs = lib.concatMapStrings (s: " -P \"${s}\"") v.useProfiles;
      extraArgs = lib.concatMapStrings (s: " \"${s}\"") v.extraArgs;
    in
    credArg + profileArgs + extraArgs;

  mkFilesScript =
    k: v:
    let
      sourcesArgs = lib.concatMapStrings (s: " ${s}") v.sources;
      asPathArg = lib.optionalString (v.asPath != null) " --as-path \"${v.asPath}\"";
    in
    pkgs.writeScript "rustic-backup-files-${k}" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # Check if repository is initialized. If 'snapshots' fails, try to initialize.
      if ! TZ="" ${cfg.package}/bin/rustic snapshots${mkGenericArgs v} >/dev/null 2>&1; then
        echo "[INFO] Repository not found or inaccessible. Attempting 'rustic init'..."
        TZ="" ${cfg.package}/bin/rustic init${mkGenericArgs v}
      fi

      TZ="" ${cfg.package}/bin/rustic backup${sourcesArgs}${asPathArg}${mkGenericArgs v}
    '';

  mkCommandScript =
    k: v:
    let
      commandArg = " --stdin-command \"${v.command}\" -";
      stdinFilenameArg = lib.optionalString (v.filename != null) " --stdin-filename \"${v.filename}\"";
    in
    pkgs.writeScript "rustic-backup-command-${k}" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # Check if repository is initialized. If 'snapshots' fails, try to initialize.
      if ! TZ="" ${cfg.package}/bin/rustic snapshots${mkGenericArgs v} >/dev/null 2>&1; then
        echo "[INFO] Repository not found or inaccessible. Attempting 'rustic init'..."
        TZ="" ${cfg.package}/bin/rustic init${mkGenericArgs v}
      fi

      TZ="" ${cfg.package}/bin/rustic backup${commandArg}${stdinFilenameArg}${mkGenericArgs v}
    '';

  commonOptions = {
    startAt = lib.mkOption {
      type = with lib.types; either (listOf str) str;
      description = ''
        Time(s) at which to run this operation.

        The format is documented in `man systemd.time`.
      '';
    };

    useProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Config profiles to use";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command-line arguments to pass to the `rustic` call.";
    };

    credentialsProfile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = cfg.credentialsProfile;
      defaultText = lib.literalExpression "config.services.rustic.credentialsProfile";
      description = "Path to the credentials file on disk. Loaded securely via systemd LoadCredential.";
    };
  };

  commonBackupOptions = commonOptions;
in
{
  options.services.rustic-new = {
    enable = lib.mkEnableOption "rustic";
    package = lib.mkPackageOption pkgs "rustic" { };

    credentialsProfile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Global credentials profile to use for all rustic operations.
        This file will be loaded via systemd `LoadCredential` to keep it out of the nix store.
      '';
    };

    checkProfiles = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        If enabled, checks that the generated rustic profiles are valid.

        Note that imports that cannot be resolved are accepted. This allows
        the recommended setup of using an imported file that only root can read
        to store the passwords.
      '';
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf tomlFormat.type;
      default = { };
      description = ''
        Configuration files for rustic, see
        <https://github.com/rustic-rs/rustic/blob/main/config/README.md>
        for supported settings.

        The `rustic` profile will be the one used by default.

        Note that this will be world-readable in the nix store, so do not put
        your passwords here! Instead, you should write them somewhere safe, and
        use the `credentialsProfile` option to load them.
      '';
    };

    backups = {
      files = lib.mkOption {
        default = { };
        description = "Backup files and directories.";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = commonBackupOptions // {
              runAs = lib.mkOption {
                type = lib.types.str;
                default = "root";
                description = "User to run the backup as.";
              };

              sources = lib.mkOption {
                type = lib.types.listOf lib.types.path;
                default = [ ];
                description = ''
                  List of sources to backup.

                  Defaults to the ones defined in the relevant configuration files.
                '';
              };

              asPath = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Manually set the backup path in snapshot";
              };
            };
          }
        );
      };

      command = lib.mkOption {
        default = { };
        description = "Backup the output of a command.";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = commonBackupOptions // {
              runAs = lib.mkOption {
                type = lib.types.str;
                description = "User to run the backup as. Mandatory for command backups.";
              };

              command = lib.mkOption {
                type = lib.types.str;
                description = "Command of which to backup the output";
              };

              filename = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  Filename to use in the backup.

                  Defaults to the profile-provided filename, or `stdin`.
                '';
              };
            };
          }
        );
      };

      postgres = lib.mkOption {
        default = { };
        description = ''
          Backup all postgresql databases.

          Use a custom `command` using `pg_dump` if you want to backup a single
          database.

          This backs up globals and individual databases in independent files.
        '';
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = commonBackupOptions // {
              runAs = lib.mkOption {
                type = lib.types.str;
                default = "rustic-postgres-ro";
                description = "User to run the backup as.";
              };

              prefix = lib.mkOption {
                type = lib.types.str;
                default = "/postgres";
                description = "Path prefix for the dumps.";
              };
            };
          }
        );
      };
    };

    checks = lib.mkOption {
      default = { };
      description = ''
        Check configurations.

        Each key is the name of the check, and the value is the parameters
        with which this check will be run. This allows setting multiple check
        running at different intervals, eg. a frequent metadata-only check and
        an infrequent full-data check.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = commonOptions // {
            runAs = lib.mkOption {
              type = lib.types.str;
              default = "root";
              description = "User to run the check as.";
            };
          };
        }
      );
    };

    prune = commonOptions // {
      enable = lib.mkEnableOption "rustic-prune";
      runAs = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "User to run the prune operation as.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."rustic-postgres-ro" = lib.mkIf (cfg.backups.postgres != { }) {
      isSystemUser = true;
      group = "rustic-postgres-ro";
    };
    users.groups."rustic-postgres-ro" = lib.mkIf (cfg.backups.postgres != { }) { };

    services.postgresql.ensureUsers = lib.optional (cfg.backups.postgres != { }) {
      name = "rustic-postgres-ro";
    };

    system.checks = lib.optional cfg.checkProfiles (
      pkgs.runCommand "rustic-profiles-check" { } ''
        ${lib.concatMapStrings (p: ''
          ln -s ${p} ./rustic-config-for-checking.toml
          ${cfg.package}/bin/rustic show-config -P rustic-config-for-checking > /dev/null
          rm ./rustic-config-for-checking.toml
        '') (lib.attrValues configFiles)}
        touch $out
      ''
    );

    environment.systemPackages = [ cfg.package ];

    environment.etc = lib.mapAttrs' (k: v: {
      name = "rustic/${k}.toml";
      value.source = v;
    }) configFiles;

    systemd.services =
      let
        filesServices = lib.mapAttrs' (
          k: v:
          lib.nameValuePair "rustic-backup-${k}" {
            serviceConfig = {
              Type = "oneshot";
              User = v.runAs;
              ExecStart = "${mkFilesScript k v}";
            }
            // lib.optionalAttrs (v.credentialsProfile != null) {
              LoadCredential = "rustic-creds.toml:${v.credentialsProfile}";
            };
            startAt = v.startAt;
          }
        ) cfg.backups.files;

        commandServices = lib.mapAttrs' (
          k: v:
          lib.nameValuePair "rustic-backup-${k}" {
            serviceConfig = {
              Type = "oneshot";
              User = v.runAs;
              ExecStart = "${mkCommandScript k v}";
            }
            // lib.optionalAttrs (v.credentialsProfile != null) {
              LoadCredential = "rustic-creds.toml:${v.credentialsProfile}";
            };
            startAt = v.startAt;
          }
        ) cfg.backups.command;

        postgresServices = lib.concatMapAttrs (
          k: v:
          let
            systemctl = "${config.systemd.package}/bin/systemctl";
            starter = pkgs.writeScript "rustic-postgres-starter-${k}" ''
              #!${pkgs.bash}/bin/bash
              set -euo pipefail

              ${systemctl} start --no-block rustic-postgres-globals-${k}.service

              ${pkgs.sudo}/bin/sudo -u postgres \
                ${config.services.postgresql.package}/bin/psql \
                -c 'SELECT datname FROM pg_database WHERE datallowconn = true' \
                --csv \
                | tail -n +2 \
                | grep -Ev '^template[0-1]$' \
                | xargs -I {} \
                ${systemctl} start --no-block rustic-postgres-db-${k}@{}.service
            '';

            globalsConfig = v // {
              filename = "${v.prefix}/globals.sql";
              command = "${config.services.postgresql.package}/bin/pg_dumpall --globals-only";
            };

            dbConfig = v // {
              filename = "$2";
              command = "${config.services.postgresql.package}/bin/pg_dump $1";
            };
          in
          {
            "rustic-backup-${k}" = {
              serviceConfig = {
                Type = "oneshot";
                User = "root";
                ExecStart = "${starter}";
              };
              startAt = v.startAt;
            };

            "rustic-postgres-globals-${k}" = {
              serviceConfig = {
                Type = "oneshot";
                User = v.runAs;
                ExecStart = "${mkCommandScript "postgres-globals-${k}" globalsConfig}";
              }
              // lib.optionalAttrs (v.credentialsProfile != null) {
                LoadCredential = "rustic-creds.toml:${v.credentialsProfile}";
              };
            };

            "rustic-postgres-db-${k}@" = {
              serviceConfig = {
                Type = "oneshot";
                User = v.runAs;
                ExecStart = "${mkCommandScript "postgres-db-${k}" dbConfig} '%i' '${v.prefix}/db/%i.sql'";
              }
              // lib.optionalAttrs (v.credentialsProfile != null) {
                LoadCredential = "rustic-creds.toml:${v.credentialsProfile}";
              };
            };
          }
        ) cfg.backups.postgres;

        checksServices = lib.mapAttrs' (
          k: v:
          lib.nameValuePair "rustic-check-${k}" {
            serviceConfig = {
              Type = "oneshot";
              User = v.runAs;
              ExecStart = "${cfg.package}/bin/rustic check${mkGenericArgs v}";
            }
            // lib.optionalAttrs (v.credentialsProfile != null) {
              LoadCredential = "rustic-creds.toml:${v.credentialsProfile}";
            };
            startAt = v.startAt;
          }
        ) cfg.checks;

        pruneService = lib.optionalAttrs cfg.prune.enable {
          "rustic-prune" = {
            serviceConfig = {
              Type = "oneshot";
              User = cfg.prune.runAs;
              ExecStart = "${cfg.package}/bin/rustic forget --prune${mkGenericArgs cfg.prune}";
            }
            // lib.optionalAttrs (cfg.prune.credentialsProfile != null) {
              LoadCredential = "rustic-creds.toml:${cfg.prune.credentialsProfile}";
            };
            startAt = cfg.prune.startAt;
          };
        };
      in
      {
        postgresql = lib.mkIf (cfg.backups.postgres != { }) {
          postStart = lib.mkAfter ''
            $PSQL -tA -c "GRANT pg_read_all_data TO \"rustic-postgres-ro\";" || true
          '';
        };
      }
      // filesServices
      // commandServices
      // postgresServices
      // checksServices
      // pruneService;
  };
}
