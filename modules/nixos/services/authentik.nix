{
  config,
  lib,
  inputs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) str;

  cfg = config.ataraxia.services.authentik;
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.authentik ];

  options.ataraxia.services.authentik = {
    enable = mkEnableOption "Enable authentik service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.authentik-env.sopsFile = secretsDir + /${cfg.sopsDir}/authentik.yaml;
    sops.secrets.authentik-ldap.sopsFile = secretsDir + /${cfg.sopsDir}/authentik.yaml;
    sops.secrets.authentik-env.restartUnits = [
      "authentik-server.service"
      "authentik-worker.service"
    ];
    sops.secrets.authentik-ldap.restartUnits = [ "authentik-ldap-outpost.service" ];

    backups.postgresql.authentik = { };

    services.authentik = {
      enable = true;
      logLevel = "info";
      listen.address = "127.0.0.1";
      listen.http = 9000;
      listen.https = 9443;
      environmentFile = config.sops.secrets.authentik-env.path;
      outposts.ldap = {
        enable = true;
        host = "https://auth.ataraxiadev.com";
        environmentFile = config.sops.secrets.authentik-ldap.path;
        listen.address = "127.0.0.1";
        listen.ldap = 3389;
        listen.ldaps = 6636;
      };
    };
  };
}
