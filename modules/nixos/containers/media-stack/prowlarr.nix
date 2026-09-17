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
        # Tags: latest, 2.6.5, version-2.6.5.5623
        image = "docker.io/linuxserver/prowlarr@sha256:c96b56d94d116a9f4de94bc23d3381689492e6c3cfb7435320e8d982e406f99a";
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
