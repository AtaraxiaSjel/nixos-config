{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    prowlarr = mkEnableOption "Enable prowlarr container";
  };

  config = mkIf cfg.prowlarr {
    virtualisation.quadlet.containers.prowlarr = {
      autoStart = true;
      containerConfig = {
        # Tags: 2.0.5, version-2.0.5.5160, 2.0.5.5160-ls129
        image = "docker.io/linuxserver/prowlarr@sha256:366914352b21e79733f1bad1c3840ca679a55dc4875754eec06ccbcc49b649d1";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/prowlarr:/config"
        ];
      };
    };
  };
}
