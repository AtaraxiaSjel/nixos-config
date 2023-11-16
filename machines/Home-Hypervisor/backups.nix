{ config, ... }:
let
  secret-conf = { services = [ "rustic-backups-nas.service" ]; };
in {
  secrets.rustic-nas-pass = secret-conf;
  secrets.rclone-nas-config = secret-conf;
  services.rustic.backups = rec {
    nas-backup = {
      backup = true;
      prune = false;
      initialize = false;
      rcloneConfigFile = config.secrets.rclone-nas-config.decrypted;
      timerConfig = {
        OnCalendar = "05:00";
        Persistent = true;
      };
      settings = {
        repository = {
          repository = "rclone:rustic-b2:ataraxia-nas-backup";
          password-file = config.secrets.rustic-nas-pass.decrypted;
        };
        copy = {
          targets = [{
            repository = "rclone:gdrive:rustic-backup/nas-backup";
            password-file = config.secrets.rustic-nas-pass.decrypted;
          }];
        };
        repository.options = {
          timeout = "10min";
        };
        backup = {
          ignore-devid = true;
          glob = [
            "!/media/nas/**/cache"
            "!/media/nas/**/.cache"
            "!/media/nas/**/log"
            "!/media/nas/**/logs"
            "!/media/nas/media-stack/configs/lidarr/config/MediaCover"
            "!/media/nas/media-stack/configs/qbittorrent/downloads"
            "!/media/nas/media-stack/configs/recyclarr/repositories"
            "!/srv/gitea"
          ];
          sources = [{
            source = "/srv /media/nas/containers /media/nas/media-stack/configs";
          }];
        };
        forget = {
          prune = true;
          keep-daily = 7;
          keep-weekly = 5;
          keep-monthly = 2;
        };
      };
    };
    nas-prune = nas-backup // {
      backup = false;
      prune = true;
      timerConfig = {
        OnCalendar = "Mon, 07:00";
        Persistent = true;
      };
    };
  };
}