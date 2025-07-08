{
  config,
  lib,
  inputs,
  secretsDir,
  ...
}:
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rustic ];

  sops.secrets.rustic-nas-pass.sopsFile = secretsDir + /rustic.yaml;
  sops.secrets.rustic-backups-s3-env.sopsFile = secretsDir + /rustic.yaml;
  services.rustic.backups =
    let
      label = "hypervisor-nas";
    in
    rec {
      nas-backup = {
        backup = true;
        prune = false;
        initialize = true;
        environmentFile = config.sops.secrets.rustic-backups-s3-env.path;
        extraEnvironment = {
          https_proxy = "http://10.10.10.6:8888";
        };
        pruneOpts = [ "--repack-cacheable-only=false" ];
        timerConfig = {
          OnCalendar = "05:00";
          Persistent = true;
        };
        settings = {
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
          repository.options = {
            timeout = "2min";
            retry = "5";
          };
          backup = {
            host = config.networking.hostName;
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
            snapshots = [
              {
                sources = [
                  "/srv /media/nas/containers"
                  "/media/nas/media-stack/configs"
                ];
              }
            ];
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
      nas-prune = lib.recursiveUpdate nas-backup {
        backup = false;
        prune = true;
        initialize = false;
        createWrapper = false;
        timerConfig = {
          OnCalendar = "Tue, 07:00";
          Persistent = true;
        };
      };
    };
}
