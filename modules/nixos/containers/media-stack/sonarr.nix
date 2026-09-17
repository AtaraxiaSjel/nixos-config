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
        # updater: strategy=semver-best, semver=>=4.0,<5.0
        # Tags: 4.0.20.3014-ls325, latest, 4.0.20
        image = "docker.io/linuxserver/sonarr@sha256:a5c1a5fecbef946927ab90ad68df319ac5fe644057e5fc18cd993f01ac07b2b2";
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
