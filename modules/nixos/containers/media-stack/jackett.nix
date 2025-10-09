{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    jackett = mkEnableOption "Enable jackett container";
  };

  config = mkIf cfg.jackett {
    virtualisation.quadlet.containers.jackett = {
      autoStart = true;
      containerConfig = {
        # Tags: 0.24.95, version-v0.24.95, v0.24.95-ls179
        image = "docker.io/linuxserver/jackett@sha256:fa1598851a2c365da12ff565cc66f42bcaee1500318ef8001e13dfcc48f0f3aa";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/jackett:/config"
        ];
      };
    };
  };
}
