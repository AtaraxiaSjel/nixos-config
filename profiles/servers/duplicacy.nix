# { config, lib, pkgs, ... }:
# let
#   start-backup = ''
#     #!${pkgs.runtimeShell}
#     export DUPLICACY_GCD_TOKEN=/var/secrets/gcd-token
#     export DUPLICACY_PASSWORD=$(cat /var/secrets/duplicacy-pass)

#     if [ ! -d "/backups/.duplicacy" ]; then
#       echo "First init duplicacy repo with \"duplicacy init -e gcd://<folder-in-gdisk>\""
#       exit 1
#     fi

#     if [ ! -d "/backups/var" ]; then
#       mkdir -p /backups/var
#     fi

#     if [ ! -L "/backups/var/dkim" ]; then
#       ln -s /var/dkim /backups/var/dkim
#     fi

#     if [ ! -L "/backups/var/vmail" ]; then
#       ln -s /var/vmail /backups/var/vmail
#     fi

#     if [ ! -L "/backups/var/microbin" ]; then
#       ln -s /var/microbin /backups/var/microbin
#     fi

#     if [ ! -L "/backups/gitea" ]; then
#       ln -s /gitea /backups/gitea
#     fi

#     if [ ! -d "/backups/srv" ]; then
#       mkdir -p /backups/var
#     fi

#     if [ ! -L "/backups/srv/joplin" ]; then
#       ln -s /srv/joplin /backups/srv/joplin
#     fi

#     cd /backups
#     duplicacy backup
#   '';
#   start-prune = ''
#     #!${pkgs.runtimeShell}
#     export DUPLICACY_GCD_TOKEN=/var/secrets/gcd-token;
#     export DUPLICACY_PASSWORD=$(cat /var/secrets/duplicacy-pass);

#     if [ ! -d "/backups/.duplicacy" ]; then
#       echo "First init duplicacy repo with \"duplicacy init -e gcd://<folder-in-gdisk>\""
#       exit 1
#     fi
#     cd /backups
#     duplicacy prune -keep 0:30 -keep 7:14 -keep 1:7
#   '';
# in {
#   secrets.gcd-token.services = [ ];
#   secrets.duplicacy-pass.services = [ ];

#   systemd.services.duplicacy-backup = {
#     serviceConfig.Type = "oneshot";
#     path = [ pkgs.duplicacy ];
#     script = start-backup;
#   };

#   systemd.timers.duplicacy-backup = {
#     wantedBy = [ "timers.target" ];
#     partOf = [ "duplicacy-backup.service" ];
#     timerConfig.OnCalendar = [ "*-*-* 05:00:00" ];
#   };

#   systemd.services.duplicacy-prune = {
#     serviceConfig.Type = "oneshot";
#     path = [ pkgs.duplicacy ];
#     script = start-prune;
#   };

#   systemd.timers.duplicacy-prune = {
#     wantedBy = [ "timers.target" ];
#     partOf = [ "duplicacy-prune.service" ];
#     timerConfig.OnCalendar = [ "*-*-* 01:00:00" ];
#   };

#   # FIXME!
#   persist.state.directories = lib.mkIf config.deviceSpecific.devInfo.fileSystem != "zfs"
#     [ "/backup" ];
# }
{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  pass-path = "/tmp/pass";
  gcd-path = "/tmp/gcd-token";
  config-path = "/repo";
  config-host-path = "/var/lib/duplicacy";
in {
  secrets.duplicacy-pass.services = [ "${backend}-duplicacy.service" ];
  secrets.gcd-token.services = [ "${backend}-duplicacy.service" ];

  virtualisation.oci-containers.containers.duplicacy = {
    autoStart = true;
    environment = rec {
      BACKUP_NAME = "homelab-duplicacy-backup";
      BACKUP_ENCRYPTION_KEY_FILE = pass-path;
      BACKUP_SCHEDULE = "0 8 * * *";
      BACKUP_LOCATION = "gcd://backups/${BACKUP_NAME}";
      GCD_TOKEN = gcd-path;
      # DUPLICACY_INIT_OPTIONS = "-storage-name ${BACKUP_NAME}";
      # If backing up from hdd, change threads to 1
      DUPLICACY_BACKUP_OPTIONS = "-threads 8 -stats";
      DUPLICACY_PRUNE_OPTIONS = "-keep 0:360 -keep 30:180 -keep 7:30";
      PRUNE_SCHEDULE = "0 9 * * *";
      DUPLICACY_CONFIG_PATH = config-path;
    };
    image = "docker.io/ataraxiadev/duplicacy-autobackup";
    volumes = [
      "/srv:/data:ro" # backup folder
      "${config-host-path}:${config-path}" # path to .duplicacy config
      "${config.secrets.duplicacy-pass.decrypted}:${pass-path}:ro"
      "${config.secrets.gcd-token.decrypted}:${gcd-path}:ro"
    ];
  };

  persist.state.directories = [ config-host-path ];
}