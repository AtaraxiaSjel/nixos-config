{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    radarr = mkEnableOption "Enable radarr container";
  };

  config = mkIf cfg.radarr {
    virtualisation.quadlet.containers.radarr = {
      autoStart = true;
      containerConfig = {
        # Tags: 6.0.4, version-6.0.4.10291, 6.0.4.10291-ls295
        image = "docker.io/linuxserver/radarr@sha256:ca43905eaf2dd11425efdcfe184892e43806b1ae0a830440c825cecbc2629cfb";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/radarr:/config"
          "${nas-path}:/data"
        ];
      };
    };
  };
}
