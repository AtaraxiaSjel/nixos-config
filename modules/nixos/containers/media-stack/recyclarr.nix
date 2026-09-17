{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    recyclarr = mkEnableOption "Enable recyclarr container";
  };

  config = mkIf cfg.recyclarr {
    virtualisation.quadlet.containers.recyclarr = {
      autoStart = true;
      containerConfig = {
        # updater: strategy=semver-best, semver=>=8.0,<9.0
        # Tags: 8.7.2
        image = "ghcr.io/recyclarr/recyclarr@sha256:6e69e009e1cd7493ff6093e8e187b5d3788c75b4a2c0c5127b6a1beda1c19728";
        pod = pods.media-stack.ref;
        user = "1000:100";
        environments = {
          CRON_SCHEDULE = "@daily";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/recyclarr:/config"
        ];
      };
    };
  };
}
