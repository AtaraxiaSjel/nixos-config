{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    sonarr = mkEnableOption "Enable sonarr container";
  };

  config = mkIf cfg.sonarr {
    virtualisation.quadlet.containers.sonarr = {
      autoStart = true;
      containerConfig = {
        # Tags: 4.0.17, version-4.0.17.2952, 4.0.17.2952-ls314
        image = "docker.io/linuxserver/sonarr@sha256:02bc962946fef994e67a38152446df25c10a52f8583aefeeb6467f9dd44cab99";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/sonarr:/config"
          "${nas-path}:/data"
        ];
      };
    };
  };
}
