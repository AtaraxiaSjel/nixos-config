{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    medusa = mkEnableOption "Enable medusa container";
  };

  config = mkIf cfg.medusa {
    virtualisation.quadlet.containers.medusa = {
      autoStart = true;
      containerConfig = {
        # Tags: 1.0.22, version-v1.0.22, v1.0.22-ls230
        image = "docker.io/linuxserver/medusa@sha256:89d7397b64b079050d8d20284fc692aee36a196885f57e5d9a396455d58a130d";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Moscow";
        };
        volumes = [
          "${nas-path}/configs/medusa:/config"
          "${nas-path}:/data"
        ];
      };
    };
  };
}
