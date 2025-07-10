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
        # Tags: 7.4.1, 7.4, 7
        image = "ghcr.io/recyclarr/recyclarr@sha256:759540877f95453eca8a26c1a93593e783a7a824c324fbd57523deffb67f48e1";
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
