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
        # Tags: 2.14.5, version-2.14.5.4836, 2.14.5.4836-ls7
        image = "docker.io/linuxserver/lidarr@sha256:fc10fbd834e83c3f984c13a12c4fd663b23a8ed83e31f346650571f0a7aeeea7";
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
