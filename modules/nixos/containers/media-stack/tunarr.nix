{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    tunarr = mkEnableOption "Enable tunarr container";
  };

  config = mkIf cfg.tunarr {
    virtualisation.quadlet.containers.tunarr = {
      autoStart = true;
      containerConfig = {
        # Tags: 1.3.8, latest
        image = "docker.io/chrisbenincasa/tunarr@sha256:88122a21c21e62c3786db786cb2725f2b94da538ea613d08febb67bf3d912e3e";
        pod = pods.media-stack.ref;
        devices = [ "/dev/dri/renderD128" ];
        environments = {
          TZ = "Europe/Moscow";
          TUNARR_SERVER_PORT = ports.tunarr.str;
          TUNARR_LOG_LEVEL = "warn";
        };
        volumes = [ "${nas-path}/configs/tunarr:/config/tunarr" ];
      };
    };
  };
}
