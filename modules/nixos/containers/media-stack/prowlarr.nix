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
        # Tags: 2.3.0, version-2.3.0.5236, 2.3.0.5236-ls139
        image = "docker.io/linuxserver/prowlarr@sha256:9ef5d8bf832edcacb6082f9262cb36087854e78eb7b1c3e1d4375056055b2d82";
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
