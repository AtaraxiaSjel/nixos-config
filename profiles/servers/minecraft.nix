{ config, pkgs, lib, inputs, ... }:
let
  jre21 = pkgs.temurin-bin;
  jre17 = pkgs.temurin-bin-17;
  jvmOpts = lib.concatStringsSep " " [
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+UseZGC"
    "-XX:+ZGenerational"
    "-XX:-ZUncommit"
    "-XX:-ZProactive"
    "-XX:+AlwaysPreTouch"
    "-XX:+UseTransparentHugePages"
  ];

  rsyncSSHKeys = config.users.users.${config.mainuser}.openssh.authorizedKeys.keys;

  defaults = {
    allow-flight = true;
    difficulty = 2;
    # 5 minutes tick timeout, for heavy packs
    max-tick-time = 5 * 60 * 1000;
    online-mode = false;
    spawn-protection = 0;
  };

  instances = config.services.modded-minecraft-servers.instances;
in
{
  imports = [
    inputs.mms.module
    inputs.ataraxiasjel-nur.nixosModules.rustic
  ];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      statech = {
        enable = false;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "6144m";
        jvmInitialAllocation = "6144m";
        jvmPackage = jre17;
        serverConfig = defaults // {
          server-port = 25567;
          rcon-port = 25568;
          motd = "StaTech";
          max-world-size = 50000;
          level-seed = "-4411466874705470064";
        };
      };
      all-of-create = {
        enable = true;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "4096m";
        jvmInitialAllocation = "4096m";
        jvmPackage = jre21;
        serverConfig = defaults // {
          server-port = 25565;
          rcon-port = 25566;
          motd = "All of Create";
          max-world-size = 50000;
          level-seed = "-6893059259197159072";
        };
      };
    };
  };
  persist.state.directories = map (x: "/var/lib/mc-${x}") (lib.attrNames instances);

  # Rustic backup for all servers, including disabled ones
  sops.secrets.rustic-workstation-pass.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  sops.secrets.rustic-minecraft-s3-env.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  services.rustic.backups = rec {
    workstation-minecraft-backup = {
      backup = true;
      prune = false;
      initialize = false;
      environmentFile = config.sops.secrets.rustic-minecraft-s3-env.path;
      pruneOpts = [ "--repack-cacheable-only=false" ];
      timerConfig = {
        OnCalendar = "*:0/15";
      };
      backupPrepareCommand = ''
        start_backup=false
        ${lib.strings.concatLines (
          map (x: "systemctl is-active --quiet mc-${x}.service && start_backup=true") (
            lib.attrNames instances
          )
        )}
        if [ "$start_backup" = false ]; then
          echo "No Minecraft servers are running. Skip backup."
          exit 1
        fi

        ${lib.strings.concatLines (
          map (x: ''
            if systemctl is-active --quiet mc-${x}.service; then
              export MCRCON_PORT=${toString instances.${x}.serverConfig.rcon-port}
              export MCRCON_PASS=${instances.${x}.serverConfig.rcon-password}
              ${pkgs.mcrcon}/bin/mcrcon "say Rustic backup is started!" save-off "save-all"
            fi
          '') (lib.attrNames instances)
        )}
        sleep 3
      '';
      backupCleanupCommand = ''
        ${lib.strings.concatLines (
          map (x: ''
            if systemctl is-active --quiet mc-${x}.service; then
              export MCRCON_PORT=${toString instances.${x}.serverConfig.rcon-port}
              export MCRCON_PASS=${instances.${x}.serverConfig.rcon-password}
              ${pkgs.mcrcon}/bin/mcrcon "say Rustic backup is done!" save-on
            fi
          '') (lib.attrNames instances)
        )}
      '';
      settings = let
        label = "workstation-minecraft";
      in {
        repository = {
          repository = "opendal:s3";
          password-file = config.sops.secrets.rustic-workstation-pass.path;
          options = {
            root = label;
            bucket = "rustic-backups";
            region = "us-east-1";
            endpoint = "https://s3.ataraxiadev.com";
          };
        };
        backup = {
          host = config.device;
          label = label;
          ignore-devid = true;
          group-by = "label";
          skip-identical-parent = true;
          glob = [ "!/var/lib/**/backups" ];
          sources = [{
            source = lib.strings.concatStringsSep " " (map (x: "/var/lib/mc-${x}") (lib.attrNames instances));
          }];
        };
        forget = {
          filter-label = [ label ];
          group-by = "label";
          prune = true;
          keep-hourly = 6;
          keep-daily = 2;
          keep-weekly = 1;
          keep-monthly = 0;
        };
      };
    };
    workstation-minecraft-prune = workstation-minecraft-backup // {
      backup = false;
      prune = true;
      createWrapper = false;
      backupPrepareCommand = null;
      backupCleanupCommand = null;
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
