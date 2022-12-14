{ config, lib, pkgs, ... }:
let
  start-backup = ''
    #!${pkgs.runtimeShell}
    export DUPLICACY_GCD_TOKEN=/var/secrets/gcd-token
    export DUPLICACY_PASSWORD=$(cat /var/secrets/duplicacy-pass)

    if [ ! -d "/backups/.duplicacy" ]; then
      echo "First init duplicacy repo with \"duplicacy init -e gcd://<folder-in-gdisk>\""
      exit 1
    fi

    if [ ! -d "/backups/var" ]; then
      mkdir -p /backups/var
    fi

    if [ ! -L "/backups/var/dkim" ]; then
      ln -s /var/dkim /backups/var/dkim
    fi

    if [ ! -L "/backups/var/vmail" ]; then
      ln -s /var/vmail /backups/var/vmail
    fi

    if [ ! -L "/backups/var/microbin" ]; then
      ln -s /var/microbin /backups/var/microbin
    fi

    if [ ! -L "/backups/gitea" ]; then
      ln -s /gitea /backups/gitea
    fi

    cd /backups
    duplicacy backup
  '';
  start-prune = ''
    #!${pkgs.runtimeShell}
    export DUPLICACY_GCD_TOKEN=/var/secrets/gcd-token;
    export DUPLICACY_PASSWORD=$(cat /var/secrets/duplicacy-pass);

    if [ ! -d "/backups/.duplicacy" ]; then
      echo "First init duplicacy repo with \"duplicacy init -e gcd://<folder-in-gdisk>\""
      exit 1
    fi
    cd /backups
    duplicacy prune -keep 0:30 -keep 7:14 -keep 1:7
  '';
in {
  secrets.gcd-token.services = [ ];
  secrets.duplicacy-pass.services = [ ];

  systemd.services.duplicacy-backup = {
    serviceConfig.Type = "oneshot";
    path = [ pkgs.duplicacy ];
    script = start-backup;
  };

  systemd.timers.duplicacy-backup = {
    wantedBy = [ "timers.target" ];
    partOf = [ "duplicacy-backup.service" ];
    timerConfig.OnCalendar = [ "*-*-* 05:00:00" ];
  };

  systemd.services.duplicacy-prune = {
    serviceConfig.Type = "oneshot";
    path = [ pkgs.duplicacy ];
    script = start-prune;
  };

  systemd.timers.duplicacy-prune = {
    wantedBy = [ "timers.target" ];
    partOf = [ "duplicacy-prune.service" ];
    timerConfig.OnCalendar = [ "*-*-* 01:00:00" ];
  };

  # FIXME!
  persist.state.directories = lib.mkIf config.deviceSpecific.devInfo.fileSystem != "zfs"
    [ "/backup" ];
}