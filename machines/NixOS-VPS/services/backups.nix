{ config, pkgs, lib, ... }: {
  services.restic.backups.vps-data = {
    initialize = true;
    passwordFile = "/srv/restic-pass";
    repositoryFile = "/srv/restic-repo";
    paths = [ "/srv" ];
    exclude = [ "/srv/restic-pass" "/srv/restic-repo" ];
    environmentFile = "${pkgs.writeText "restic.env" "GOMAXPROCS=1"}";
    extraBackupArgs = [ "--no-scan" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-yearly 2"
    ];
  };
}