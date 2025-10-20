{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    radarr = mkEnableOption "Enable radarr container";
  };

  config = mkIf cfg.radarr {
    virtualisation.quadlet.containers.radarr = {
      autoStart = true;
      containerConfig = {
        # Tags: 5.28.0, version-5.28.0.10274, 5.28.0.10274-ls285
        image = "docker.io/linuxserver/radarr@sha256:fae2aafa6ecace3524fc79d102f5bfd25fb151caed6a454cee46479236ac33bf";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/radarr:/config"
          "${nas-path}:/data"
        ];
      };
    };
  };
}
