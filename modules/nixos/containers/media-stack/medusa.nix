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
        # Tags: 1.0.22, version-v1.0.22, v1.0.22-ls236
        image = "docker.io/linuxserver/medusa@sha256:9e0d4b0251f7f0cd4cb83478de0d395cff8f5bc3138c385b0bfc0cd4d98c90a3";
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
