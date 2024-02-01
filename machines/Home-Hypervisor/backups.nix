{ config, inputs, ... }: {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rustic ];

  sops.secrets.rustic-nas-pass.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  sops.secrets.rclone-rustic-backups.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  services.rustic.backups = rec {
    nas-backup = {
      backup = true;
      prune = false;
      initialize = false;
      extraEnvironment = { https_proxy = "http://192.168.0.6:8888"; };
      rcloneConfigFile = config.sops.secrets.rclone-rustic-backups.path;
      rcloneOptions = { fast-list = true; };
      pruneOpts = [ "--repack-cacheable-only=false" ];
      timerConfig = {
        OnCalendar = "05:00";
        Persistent = true;
      };
      settings = let
        bucket = "rustic-backups";
        label = "hypervisor-nas";
      in {
        repository = {
          repository = "rclone:rustic-backups:${bucket}/${label}";
          password-file = config.sops.secrets.rustic-nas-pass.path;
        };
        backup = {
          host = config.device;
          label = label;
          ignore-devid = true;
          group-by = "label";
          glob = [
            "!/media/nas/**/cache"
            "!/media/nas/**/.cache"
            "!/media/nas/**/log"
            "!/media/nas/**/logs"
            "!/media/nas/media-stack/configs/lidarr/config/MediaCover"
            "!/media/nas/media-stack/configs/qbittorrent/downloads"
            "!/media/nas/media-stack/configs/recyclarr/repositories"
            "!/srv/gitea"
            "!/srv/wiki"
          ];
          sources = [{
            source = "/srv /media/nas/containers /media/nas/media-stack/configs";
          }];
        };
        forget = {
          filter-label = [ label ];
          group-by = "label";
          prune = true;
          keep-daily = 4;
          keep-weekly = 2;
          keep-monthly = 0;
        };
      };
    };
    nas-prune = nas-backup // {
      backup = false;
      prune = true;
      createWrapper = false;
      timerConfig = {
        OnCalendar = "Mon, 06:00";
        Persistent = true;
      };
    };
  };
}