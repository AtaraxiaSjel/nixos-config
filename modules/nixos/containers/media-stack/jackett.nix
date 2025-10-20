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
        # Tags: 0.24.159, version-v0.24.159, v0.24.159-ls190
        image = "docker.io/linuxserver/jackett@sha256:2a84936d5b0b684a772adf40d280acd1f476a765cb4e4a91d2537e5b55a56efa";
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
