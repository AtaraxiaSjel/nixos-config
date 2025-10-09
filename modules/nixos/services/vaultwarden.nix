{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.vaultwarden;
  nginx = config.ataraxia.services.nginx;
  domain = "vw.ataraxiadev.com";

  user = config.systemd.services.backup-vaultwarden.serviceConfig.User;
  group = config.systemd.services.backup-vaultwarden.serviceConfig.Group;
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
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
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
        domain = "https://${domain}";
        extendedLogging = true;
        invitationsAllowed = false;
        useSyslog = true;
        logLevel = "warn";
        rocketAddress = "127.0.0.1";
        rocketPort = ports.vaultwarden.int;
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
        websocketPort = ports.vaultwarden-ws.int;
        webVaultEnabled = true;
      };
      environmentFile = config.sops.secrets.vaultwarden.path;
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.vaultwarden.str}";
        };
        locations."/notifications/hub" = {
          proxyPass = "http://127.0.0.1:${ports.vaultwarden-ws.str}";
          proxyWebsockets = true;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://127.0.0.1:${ports.vaultwarden.str}";
        };
      };
    };

    persist.state.directories = [
      "/var/lib/vaultwarden"
      config.services.vaultwarden.backupDir
    ];

    systemd.tmpfiles.rules = [
      "d ${config.services.vaultwarden.backupDir} 0700 ${user} ${group} -"
    ];
  };
}
