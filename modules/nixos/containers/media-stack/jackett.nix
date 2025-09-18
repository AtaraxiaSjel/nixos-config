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
        # Tags: 0.23.32, version-v0.23.32, v0.23.32-ls156
        image = "docker.io/linuxserver/jackett@sha256:19cdfb07cc5cc1863949e4d7ff8442d5d3cbe0f67d49cfa20f2d612bcc0b9e5a";
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
