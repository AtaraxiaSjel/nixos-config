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
            skip-if-unchanged = true;
            globs = [
              "!/media/nas/**/cache"
              "!/media/nas/**/.cache"
              "!/media/nas/**/log"
              "!/media/nas/**/logs"
              "!/media/nas/media-stack/configs/jellyfin/data/metadata"
              "!/media/nas/media-stack/configs/jellyfin/data/data/introskipper"
              "!/media/nas/media-stack/configs/kavita/covers"
              "!/media/nas/media-stack/configs/lidarr/config/MediaCover"
              "!/media/nas/media-stack/configs/qbittorrent/downloads"
              "!/media/nas/media-stack/configs/radarr/config/MediaCover"
              "!/media/nas/media-stack/configs/recyclarr/repositories"
              "!/media/nas/media-stack/configs/sonarr/config/MediaCover"
              "!/srv/gitea"
              "!/srv/forgejo"
              "!/srv/wiki"
            ];
            snapshots = [
              {
                sources = [
                  "/srv"
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

  sops.secrets.rustic-yandex-backup = {
    sopsFile = secretsDir + /rustic.yaml;
    owner = "vaultwarden";
  };
  sops.secrets.rustic-cloudru-backup = {
    sopsFile = secretsDir + /rustic.yaml;
    owner = "vaultwarden";
  };
  services.rustic-new = {
    enable = true;
    profiles = {
      yandex-backup = {
        repository = {
          repository = "opendal:s3";
          options = {
            endpoint = "https://storage.yandexcloud.net/";
            bucket = "ataraxia-backup";
            region = "ru-central1";
          };
        };
      };
      cloudru-backup = {
        repository = {
          repository = "opendal:s3";
          options = {
            endpoint = "https://s3.cloud.ru";
            bucket = "ataraxia-backup";
            region = "ru-central-1";
          };
        };
      };
      vaultwarden = {
        backup.label = "vaultwarden";
        global.group-by = "label";
        forget = {
          prune = true;
          keep-weekly = 4;
          keep-monthly = 2;
          keep-within = "10d";
          max-unused = "20%";
        };
      };
    };
    backups.files = {
      vaultwarden-to-yandex = {
        runAs = "vaultwarden";
        startAt = "*-*-* 02:00:00";
        sources = [ "/srv/vaultwarden" ];
        useProfiles = [
          "yandex-backup"
          "vaultwarden"
        ];
        credentialsProfile = config.sops.secrets.rustic-yandex-backup.path;
      };
      vaultwarden-to-cloudru = {
        runAs = "vaultwarden";
        startAt = "*-*-* 02:10:00";
        sources = [ "/srv/vaultwarden" ];
        useProfiles = [
          "cloudru-backup"
          "vaultwarden"
        ];
        credentialsProfile = config.sops.secrets.rustic-cloudru-backup.path;
      };
    };
  };
}
