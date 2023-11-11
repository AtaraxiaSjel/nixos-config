{ config, ... }:
let
  secret-conf = { services = [ "rustic-backups-nas.service" ]; };
in {
  secrets.rustic-gdrive-pass = secret-conf;
  secrets.rclone-gdrive = secret-conf;
  services.rustic.backups.nas = {
    initialize = true;
    passwordFile = config.secrets.rustic-gdrive-pass.decrypted;
    repository = "rclone:gdrive:rustic-backup/nas";
    rcloneConfigFile = config.secrets.rclone-gdrive.decrypted;
    extraBackupArgs = [ "--ignore-devid" ];
    paths = [
      "/media/nas/containers"
      "/media/nas/media-stack/configs"
      "/srv"
    ];
    exclude = [
      "/media/nas/**/cache"
      "/media/nas/**/.cache"
      "/media/nas/**/log"
      "/media/nas/**/logs"
      "/media/nas/media-stack/configs/lidarr/config/MediaCover"
      "/media/nas/media-stack/configs/qbittorrent/downloads"
      "/media/nas/media-stack/configs/recyclarr/repositories"
      "/srv/gitea"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 2"
      "--keep-yearly 0"
    ];
  };
}