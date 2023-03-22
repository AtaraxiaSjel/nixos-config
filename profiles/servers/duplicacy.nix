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