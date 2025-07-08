{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) str;

  cfg = config.ataraxia.services.vaultwarden;
in
{
  options.ataraxia.services.vaultwarden = {
    enable = mkEnableOption "Enable vaultwarden service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.vaultwarden.sopsFile = secretsDir + /${cfg.sopsDir}/vaultwarden.yaml;
    sops.secrets.vaultwarden.owner = config.users.users.vaultwarden.name;
    sops.secrets.vaultwarden.restartUnits = [ "vaultwarden.service" ];

    services.vaultwarden = {
      enable = true;
      backupDir = "/srv/vaultwarden";
      config = {
        domain = "https://vw.ataraxiadev.com";
        extendedLogging = true;
        invitationsAllowed = false;
        useSyslog = true;
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
      };
      environmentFile = config.sops.secrets.vaultwarden.path;
    };

    # We need to do this to successufully create backup folder
    # systemd.services.backup-vaultwarden.serviceConfig = {
    #   User = "root";
    #   Group = "root";
    # };

    persist.state.directories = [
      "/var/lib/vaultwarden"
      config.services.vaultwarden.backupDir
    ];

    systemd.tmpfiles.rules =
      let
        backupDir = config.services.vaultwarden.backupDir;
        user = config.systemd.services.backup-vaultwarden.serviceConfig.User;
        group = config.systemd.services.backup-vaultwarden.serviceConfig.Group;
      in
      [
        "d ${backupDir} 0700 ${user} ${group} -"
      ];
  };
}
