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
        # Tags: 1.0.22, version-v1.0.22, v1.0.22-ls241
        image = "docker.io/linuxserver/medusa@sha256:00fb852d94e3cb26c4d7ae345627d709d65b352de581ba363d5fede6f42d0962";
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
