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

  cfg = config.ataraxia.services.telemt;
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.telemt ];

  options.ataraxia.services.telemt = {
    enable = mkEnableOption "Enable telemt service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.telemt-config = {
      sopsFile = secretsDir + /${cfg.sopsDir}/telemt.yaml;
      owner = "telemt";
      restartUnits = [ "telemt.service" ];
    };
    services.telemt = {
      enable = true;
      configFile = config.sops.secrets.telemt-config.path;
    };
  };
}
