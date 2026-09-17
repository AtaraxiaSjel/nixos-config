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
        # Tags: v3.5.0, latest
        image = "ghcr.io/flaresolverr/flaresolverr@sha256:139dfee1c6f89249c8d665d1333a42e8ec74ec0a86bc6bb1c8461e10d3a66a47";
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
