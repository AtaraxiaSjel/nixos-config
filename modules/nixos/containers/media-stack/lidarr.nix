{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    lidarr = mkEnableOption "Enable lidarr container";
  };

  config = mkIf cfg.lidarr {
    virtualisation.quadlet.containers.lidarr = {
      autoStart = true;
      containerConfig = {
        # updater: strategy=semver-best, semver=>=3.0,<4.0
        # Tags: 3.1.6-develop, develop, develop-3.1.6.5078-ls265
        image = "docker.io/linuxserver/lidarr@sha256:a3070470a131fbd4cdf4232f400200ce22035fa8995de72deaaa78a809afb2f4";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/lidarr/config:/config"
          # "${nas-path}/configs/lidarr/custom-services.d:/custom-services.d"
          # "${nas-path}/configs/lidarr/custom-cont-init.d:/custom-cont-init.d"
          "${nas-path}:/data"
        ];
      };
    };
  };
}
