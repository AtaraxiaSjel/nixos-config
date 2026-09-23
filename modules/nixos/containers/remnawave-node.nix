{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) int str;

  cfg = config.ataraxia.containers.remnawave-node;
  hostname = config.networking.hostName;
in
{
  options.ataraxia.containers.remnawave-node = {
    enable = mkEnableOption "Enable remnawave node";
    port = mkOption {
      type = int;
      default = 2222;
      description = "Port for remnawave node";
    };
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
      restartUnits = [ "remnawave-node.service" ];
    };

    virtualisation.quadlet.containers.remnawave-node = {
      autoStart = true;
      containerConfig = {
        environments = {
          NODE_PORT = toString cfg.port;
        };
        environmentFiles = [ config.sops.secrets."remnawave-${hostname}-node".path ];
        networks = [ "host" ];
        addCapabilities = [ "NET_ADMIN" ];
        # updater: track=3
        # Tags: latest, 3.4.1
        image = "docker.io/remnawave/node@sha256:0cdf386dd49f360fc885bb34bde21132e478e40f0deac62d616086ec0fa9257e";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
