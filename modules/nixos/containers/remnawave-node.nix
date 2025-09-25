{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) str;
  inherit (config.virtualisation.quadlet) containers;

  cfg = config.ataraxia.containers.remnawave-node;
  hostname = config.networking.hostName;
in
{
  options.ataraxia.containers.remnawave-node = {
    enable = mkEnableOption "Enable remnawave node";
    sopsDir = mkOption {
      type = str;
      default = hostname;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."remnawave-${hostname}-node" = {
      sopsFile = secretsDir + /${cfg.sopsDir}/remnanode.yaml;
      restartUnits = [ containers.remnawave-node.ref ];
    };

    virtualisation.quadlet.containers.remnawave-node = {
      autoStart = true;
      containerConfig = {
        environments = {
          APP_PORT = "2222";
        };
        environmentFiles = [ config.sops.secrets."remnawave-${hostname}-node".path ];
        networks = [ "host" ];
        # Tags: 2.1.7
        image = "docker.io/remnawave/node@sha256:a660cd8514e11b5cefe1df724fe161720150eace5a3e33fae9507e4422b7b9e2";
      };
    };

    networking.firewall.allowedTCPPorts = [ 2222 ];
  };
}
