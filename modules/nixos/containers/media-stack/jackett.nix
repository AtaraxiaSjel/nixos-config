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
        # Tags: 0.22.2151, version-v0.22.2151, v0.22.2151-ls89
        image = "docker.io/linuxserver/jackett@sha256:31fe4e871f1d52190d3b76aac92cbbdb67b42623fb364038744afac59e860841";
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
