{ config, pkgs, lib, inputs, ... }:
let
  jre17 = pkgs.temurin-bin-17;
  jvmOpts = lib.concatStringsSep " " [
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=40"
    "-XX:G1MaxNewSizePercent=50"
    "-XX:G1HeapRegionSize=16M"
    "-XX:G1ReservePercent=15"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=20"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
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
in {
  imports = [ inputs.mms.module ];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      statech = {
        enable = true;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "6144m";
        jvmInitialAllocation = "6144m";
        jvmPackage = jre17;
        serverConfig = defaults // {
          server-port = 25565;
          rcon-port = 25566;
          motd = "StaTech";
          max-world-size = 50000;
          level-seed = "-4411466874705470064";
        };
      };
    };
  };
  persist.state.directories = [ "/var/lib/mc-statech" ];

  secrets.restic-mc-pass.services = [ "restic-backups-mc-servers.service" ];
  secrets.restic-mc-repo.services = [ "restic-backups-mc-servers.service" ];
  services.restic.backups.mc-servers = {
    initialize = true;
    passwordFile = config.secrets.restic-mc-pass.decrypted;
    repositoryFile = config.secrets.restic-mc-repo.decrypted;
    paths = [ "/var/lib/mc-statech" ];
    exclude = [ "/var/lib/mc-statech/backups" ];
    environmentFile = "${pkgs.writeText "restic.env" ''
      GOMAXPROCS=1
      MCRCON_PORT=25566
      MCRCON_PASS=whatisloveohbabydonthurtmedonthurtmenomore
    ''}";
    extraBackupArgs = [ "--no-scan" ];
    backupPrepareCommand = ''
      if ! systemctl is-active --quiet mc-statech.service; then
        echo "Minecraft server is not active. Skipping restic backup."
        exit 1
      fi
      ${pkgs.mcrcon}/bin/mcrcon "say Restic backup is started!" save-off "save-all"
      sleep 3
    '';
    backupCleanupCommand = ''
      systemctl is-active --quiet mc-statech.service && ${pkgs.mcrcon}/bin/mcrcon "say Restic backup is done!" save-on
    '';
    timerConfig = {
      OnCalendar = "*:0/15";
    };
    pruneOpts = [
      "--keep-last 12"
      "--keep-hourly 12"
      "--keep-daily 5"
      "--keep-weekly 2"
      "--keep-monthly 0"
      "--keep-yearly 0"
    ];
  };
}
