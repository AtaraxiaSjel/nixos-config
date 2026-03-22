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
        # Tags: 3.1.0, version-3.1.0.4875, 3.1.0.4875-ls22
        image = "docker.io/linuxserver/lidarr@sha256:dbffcf91da47d48e09e613857032c95a62755b928a71a7718688e3ab03fbbd26";
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
