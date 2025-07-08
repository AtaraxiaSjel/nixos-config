{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.virtualisation.quadlet) networks;

  cfg = config.ataraxia.containers.filestash;
  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.filestash = {
    enable = mkEnableOption "Enable filestash container";
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.filestash = {
      autoStart = true;
      containerConfig = {
        environments = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ = "Europe/Moscow";
          APPLICATION_URL = "files.ataraxiadev.com";
          CANARY = "true";
        };
        # Tags: latest
        image = "docker.io/machines/filestash@sha256:923c3399768fada3424bb6f3bc01521dad30e9a7a840cfb2eba3610b6acafffe";
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:8334:8334/tcp" ];
        volumes = [
          "${nas-path}/configs/filestash:/app/data/state"
          "${nas-path}:/mnt"
        ];
      };
    };
  };
}
