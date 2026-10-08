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

  cfg = config.ataraxia.services.syncyomi;
  # TODO: create a proper module for syncyomi
  # Move port to ports.nix file
  port = 8282;
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.syncyomi ];

  options.ataraxia.services.syncyomi = {
    enable = mkEnableOption "Enable syncyomi service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.syncyomi.sopsFile = secretsDir + /${cfg.sopsDir}/syncyomi.yaml;
    services.syncyomi.enable = true;
    services.syncyomi.configFile = config.sops.secrets.syncyomi.path;
    networking.firewall.allowedTCPPorts = [ port ];
    ataraxia.lists.ports.syncyomi = port;

    persist.state.directories = [ config.services.syncyomi.dataDir ];
  };
}
