{ config, inputs, ... }: {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rustic ];

  sops.secrets.rustic-nas-pass.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  sops.secrets.rustic-backups-s3-env.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  services.rustic.backups = rec {
    nas-backup = {
      backup = true;
      prune = false;
      initialize = false;
      environmentFile = config.sops.secrets.rustic-backups-s3-env.path;
      extraEnvironment = { https_proxy = "http://10.10.10.6:8888"; };
      pruneOpts = [ "--repack-cacheable-only=false" ];
      timerConfig = {
        OnCalendar = "05:00";
        Persistent = true;
      };
      settings = let
        label = "hypervisor-nas";
      in {
        repository = {
          repository = "opendal:s3";
          password-file = config.sops.secrets.rustic-nas-pass.path;
          options = {
            root = label;
            bucket = "ataraxia-rustic-backups";
            region = "eu-central-003";
            endpoint = "https://s3.eu-central-003.backblazeb2.com";
          };
        };
        backup = {
          host = config.device;
          label = label;
          ignore-devid = true;
          group-by = "label";
          skip-identical-parent = true;
          globs = [
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
          snapshots = [{
            sources = [ "/srv /media/nas/containers" "/media/nas/media-stack/configs" ];
          }];
        };
        forget = {
          filter-labels = [ label ];
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