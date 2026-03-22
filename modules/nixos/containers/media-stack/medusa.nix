{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    medusa = mkEnableOption "Enable medusa container";
  };

  config = mkIf cfg.medusa {
    virtualisation.quadlet.containers.medusa = {
      autoStart = true;
      containerConfig = {
        # Tags: 1.0.25, version-v1.0.25, v1.0.25-ls264
        image = "docker.io/linuxserver/medusa@sha256:8f568c3f5b6b91615beb5009480ae98395620afc3ddd86c215598ed93dd8fde3";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/medusa:/config"
          "${nas-path}:/data"
        ];
      };
    };
  };
}
