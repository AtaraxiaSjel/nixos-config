{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    sonarr = mkEnableOption "Enable sonarr container";
  };

  config = mkIf cfg.sonarr {
    virtualisation.oci-containers.containers.sonarr = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        TZ = "Europe/Moscow";
      };
      extraOptions = [ "--pod=media-stack" ];
      # Tags: 4.0.15, version-4.0.15.2941, 4.0.15.2941-ls285
      image = "docker.io/linuxserver/sonarr@sha256:1156329d544b38bd1483add75c9b72c559f20e1ca043fd2d6376c2589d38951f";
      volumes = [
        "${nas-path}/configs/sonarr:/config"
        "${nas-path}:/data"
      ];
    };
  };
}
