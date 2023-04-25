{ config, pkgs, lib, ... }:
let
  user = config.users.users.vaultwarden.name;
  group = config.users.groups.vaultwarden.name;
in {
  secrets.vaultwarden.owner = user;

  services.vaultwarden = {
    enable = true;
    backupDir = "/srv/vaultwarden";
    config = {
      domain = "https://vw.ataraxiadev.com";
      extendedLogging = true;
      invitationsAllowed = false;
      useSyslog = true;
      # logFile = "/var/log/vaultwarden.log";
      logLevel = "warn";
      rocketAddress = "127.0.0.1";
      rocketPort = 8812;
      showPasswordHint = false;
      signupsAllowed = false;
      signupsDomainsWhitelist = "ataraxiadev.com";
      signupsVerify = true;
      smtpAuthMechanism = "Login";
      smtpFrom = "vaultwarden@ataraxiadev.com";
      smtpFromName = "Vaultwarden";
      smtpHost = "mail.ataraxiadev.com";
      smtpPort = 587;
      smtpSecurity = "starttls";
      websocketAddress = "127.0.0.1";
      websocketEnabled = true;
      websocketPort = 3012;
      webVaultEnabled = true;
      # rocketWorkers = 10;
      dataDir = "/var/lib/bitwarden_rs";
    };
    environmentFile = config.secrets.vaultwarden.decrypted;
  };

  # We need to do this to successufully create backup folder
  systemd.services.backup-vaultwarden.serviceConfig = {
    User = "root";
    Group = "root";
  };

  persist.state.directories = [
    config.services.vaultwarden.dataDir
  ] ++ lib.optionals (config.deviceSpecific.devInfo.fileSystem != "zfs") [
    config.services.vaultwarden.backupDir
  ];
}