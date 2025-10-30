{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.virtualisation.quadlet) networks;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.docker-socket-proxy;
in
{
  options.ataraxia.containers.docker-socket-proxy = {
    enable = mkEnableOption "Enable docker-socket-proxy container";
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.networks = {
      dockerproxy.networkConfig = {
        internal = true;
        ipv6 = false;
      };
    };

    virtualisation.quadlet.containers.dockerproxy = {
      autoStart = true;
      containerConfig = {
        environments = {
          CONTAINERS = "1";
          SERVICES = "1";
          TASKS = "0";
          POST = "0";
        };
        healthCmd = "wget --spider http://localhost:2375/version || exit 1";
        healthInterval = "30s";
        healthRetries = 3;
        healthStartPeriod = "20s";
        healthTimeout = "5s";
        # Tags: v0.4.1, latest
        image = "docker.io/tecnativa/docker-socket-proxy@sha256:3400c429c5f9e1b21d62130fb93b16e2e772d4fb7695bd52fc2b743800b9fe9e";
        networks = [ networks.dockerproxy.ref ];
        publishPorts = [ "127.0.0.1:${ports.docker-socket-proxy.str}:2375/tcp" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
      };
    };
  };
}
