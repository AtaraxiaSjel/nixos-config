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
        # Tags: 5.27.5, version-5.27.5.10198, 5.27.5.10198-ls284
        image = "docker.io/linuxserver/radarr@sha256:f174546a0ad7eb9a9170e4142bef6f74ef3ebfe6209528fded40630369406dc0";
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
