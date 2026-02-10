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
        # Tags: 4.0.16, version-4.0.16.2944, 4.0.16.2944-ls302
        image = "docker.io/linuxserver/sonarr@sha256:6f73bbba33391a338e20d836a60c86beaf2a865a89b706b339fc8cb0b8ce1559";
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
