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
        # Tags: 4.0.15, version-4.0.15.2941, 4.0.15.2941-ls293
        image = "docker.io/linuxserver/sonarr@sha256:328d322af2bb8d7211a9c43a26ff5e658ba3e6f47a695e8fb9ff806bfeab0f04";
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
