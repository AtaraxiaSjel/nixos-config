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
        # Tags: 2.14.5, version-2.14.5.4836, 2.14.5.4836-ls6
        image = "docker.io/linuxserver/lidarr@sha256:5661b79d7245ec0c196a5a35ac13be44c6d76563d9e5bf855b3ffa3b91160999";
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
