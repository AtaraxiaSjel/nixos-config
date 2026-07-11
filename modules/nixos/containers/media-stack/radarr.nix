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
        # Tags: 6.2.1, version-6.2.1.10461, 6.2.1.10461-ls307
        image = "docker.io/linuxserver/radarr@sha256:1e95b5c13fe015361a9ae1c4d99fc2336816790aaea60fa74b2ffebe076a69e0";
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
