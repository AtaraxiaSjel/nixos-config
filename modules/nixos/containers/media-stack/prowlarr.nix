{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    prowlarr = mkEnableOption "Enable prowlarr container";
  };

  config = mkIf cfg.prowlarr {
    virtualisation.quadlet.containers.prowlarr = {
      autoStart = true;
      containerConfig = {
        # Tags: 2.3.0, version-2.3.0.5236, 2.3.0.5236-ls136
        image = "docker.io/linuxserver/prowlarr@sha256:5339e9050cfcc0cb5331e9c98610ed9d4ce70ef481a5461ea664a13dda3f1eb0";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/prowlarr:/config"
        ];
      };
    };
  };
}
