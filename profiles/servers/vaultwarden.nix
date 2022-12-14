{ config, pkgs, lib, ... }: {
  secrets.vaultwarden = {
    owner = "${toString config.users.users.vaultwarden.uid}";
    permissions = "400";
  };

  services.vaultwarden = {
    enable = true;
    backupDir = "/backups/vaultwarden";
    config = {
      domain = "https://vw.ataraxiadev.com";
      extendedLogging = true;
      invitationsAllowed = false;
      logFile = "/var/log/vaultwarden.log";
      logLevel = "warn";
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
      smtpSsl = true;
      websocketAddress = "0.0.0.0";
      websocketEnabled = true;
      websocketPort = 3012;
      webVaultEnabled = true;
      # rocketWorkers = 10;
    };
    environmentFile = config.secrets.vaultwarden.decrypted;
  };

  persist.state.directories = [ "/var/lib/bitwarden_rs" ];
}