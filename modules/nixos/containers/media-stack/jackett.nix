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
        # Tags: 0.23.38, version-v0.23.38, v0.23.38-ls157
        image = "docker.io/linuxserver/jackett@sha256:786993e836ec7bbce290b3aa48cb2789279051256896b0905ec37e6ef805db8c";
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
