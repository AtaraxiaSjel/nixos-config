{ config, pkgs, lib, ... }: {
  services.restic.backups.vps-data = {
    initialize = true;
    passwordFile = "/srv/restic-pass";
    repositoryFile = "/srv/restic-repo";
    paths = [
      "/srv"
      "/var/lib/acme"
      "/var/lib/headscale"
      "/var/lib/redis-unbound"
      "/var/lib/tailscale"
      "/var/lib/tor"
    ];
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