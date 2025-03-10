{
  config,
  inputs,
  secretsDir,
  ...
}:
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rustic ];

  sops.secrets.rustic-vps-pass.sopsFile = secretsDir + /rustic.yaml;
  sops.secrets.rustic-backups-s3-env.sopsFile = secretsDir + /rustic.yaml;
  services.rustic.backups =
    let
      cfg = config.services.rustic.backups;
      label = "vps-containers";
    in
    {
      vps-backup = {
        backup = true;
        prune = false;
        initialize = false;
        pruneOpts = [ "--repack-cacheable-only=false" ];
        environmentFile = config.sops.secrets.rustic-backups-s3-env.path;
        timerConfig = {
          OnCalendar = "01:00";
          Persistent = true;
        };
        settings = {
          repository = {
            repository = "opendal:s3";
            password-file = config.sops.secrets.rustic-vps-pass.path;
            options = {
              root = label;
              bucket = "ataraxia-rustic-backups";
              region = "eu-central-003";
              endpoint = "https://s3.eu-central-003.backblazeb2.com";
            };
          };
          repository.options = {
            timeout = "5min";
            retry = "10";
          };
          backup = {
            host = config.networking.hostName;
            label = label;
            ignore-devid = true;
            group-by = "label";
            skip-identical-parent = true;
            snapshots = [
              {
                sources = [
                  "/var/lib/tailscale"
                  "/srv/marzban"
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
            keep-monthly = 1;
          };
        };
      };
      vps-prune = cfg.vps-backup // {
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
