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
        # Tags: 8.5.1, 8.5, 8
        image = "ghcr.io/recyclarr/recyclarr@sha256:734cecf44ae9be7cf0cb05b2c1bc7da0abef9d938cc11b605e58b3146205e5c0";
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
