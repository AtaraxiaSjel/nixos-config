{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ataraxia.lists) ports;
  inherit (config.virtualisation.quadlet) networks;

  cfg = config.ataraxia.containers.flaresolverr;
  port = ports.flaresolverr.str;
in
{
  options.ataraxia.containers.flaresolverr = {
    enable = mkEnableOption "Enable flaresolverr container";
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.flaresolverr = {
      autoStart = true;
      containerConfig = {
        # Tags: latest, v3.5.2
        image = "ghcr.io/flaresolverr/flaresolverr@sha256:c80ae007ce2ccdcd217a12426e4f039ef763ff90738c808d38810c3e59323767";
        environments = {
          PORT = port;
          LOG_LEVEL = "warn";
          TZ = "Europe/Moscow";
        };
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:${port}:${port}/tcp" ];
      };
    };
  };
}
