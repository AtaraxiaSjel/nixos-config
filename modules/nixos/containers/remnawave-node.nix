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
          NODE_PORT = "2222";
        };
        environmentFiles = [ config.sops.secrets."remnawave-${hostname}-node".path ];
        networks = [ "host" ];
        # Tags: 2.2.3
        image = "docker.io/remnawave/node@sha256:d686091e004a4d870dbcf1e49fc0dad94d9676cc4d27de652bf733b55b9f974b";
      };
    };

    networking.firewall.allowedTCPPorts = [ 2222 ];
  };
}
