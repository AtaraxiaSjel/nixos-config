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
        # Tags: 3.1.0, version-3.1.0.4875, 3.1.0.4875-ls19
        image = "docker.io/linuxserver/lidarr@sha256:6fba990e5b460ea53a3f91ebac823a3471f2254669ea96036d9411fedf0f65be";
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
