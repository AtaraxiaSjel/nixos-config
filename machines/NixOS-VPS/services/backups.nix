{ config, inputs, ... }: {
  sops.secrets.rustic-vps-pass.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  sops.secrets.rclone-rustic-backups.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  services.rustic.backups = rec {
    vps-backup = {
      backup = true;
      prune = false;
      initialize = false;
      rcloneConfigFile = config.sops.secrets.rclone-rustic-backups.path;
      rcloneOptions = { fast-list = true; };
      pruneOpts = [ "--repack-cacheable-only=false" ];
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
      };
      settings = let
        bucket = "rustic-backups";
        label = "vps-containers";
      in {
        repository = {
          repository = "rclone:rustic-backups:${bucket}/${label}";
          password-file = config.sops.secrets.rustic-vps-pass.path;
        };
        repository.options = {
          timeout = "5min";
          retry = "10";
        };
        backup = {
          host = config.device;
          label = label;
          ignore-devid = true;
          group-by = "label";
          sources = [{
            source = "/srv/marzban /srv/nextcloud/config /srv/nextcloud/data";
          }];
        };
        forget = {
          filter-label = [ label ];
          group-by = "label";
          prune = true;
          keep-daily = 4;
          keep-weekly = 2;
          keep-monthly = 1;
        };
      };
    };
    vps-prune = vps-backup // {
      backup = false;
      prune = true;
      createWrapper = false;
      timerConfig = {
        OnCalendar = "Mon, 02:00";
        Persistent = true;
      };
    };
  };
}