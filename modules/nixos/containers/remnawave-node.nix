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
        # Tags: 2.5.4
        image = "docker.io/remnawave/node@sha256:ab60156026ef01f16ed4ebb0e649e0c0c0aa9b001151eb6d1a6cdb7926055774";
      };
    };

    networking.firewall.allowedTCPPorts = [ 2222 ];
  };
}
