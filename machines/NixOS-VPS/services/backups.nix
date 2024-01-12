{ config, inputs, ... }: {
  sops.secrets.rustic-repo-pass.sopsFile = inputs.self.secretsDir + /rustic-b2.yaml;
  sops.secrets.rclone-backup-config.sopsFile = inputs.self.secretsDir + /rustic-b2.yaml;

  services.rustic.backups = let
    label = "vps-containers";
  in rec {
    vps-backup = {
      backup = true;
      prune = false;
      rcloneConfigFile = config.sops.secrets.rclone-backup-config.path;
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
      };
      settings = {
        repository = {
          repository = "rclone:rustic-b2:ataraxia-nas-backup";
          password-file = config.sops.secrets.rustic-repo-pass.path;
        };
        repository.options = {
          timeout = "10min";
        };
        backup = {
          host = config.device;
          label = label;
          ignore-devid = true;
          sources = [{
            source = "/srv/marzban /srv/nextcloud/config /srv/nextcloud/data";
          }];
        };
        forget = {
          filter-label = [ label ];
          prune = true;
          keep-daily = 5;
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
        OnCalendar = "Tue, 02:00";
        Persistent = true;
      };
    };
  };
}