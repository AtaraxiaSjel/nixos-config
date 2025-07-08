{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    radarr = mkEnableOption "Enable radarr container";
  };

  config = mkIf cfg.radarr {
    virtualisation.oci-containers.containers.radarr = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        TZ = "Europe/Moscow";
      };
      extraOptions = [ "--pod=media-stack" ];
      # Tags: 5.26.2, version-5.26.2.10099, 5.26.2.10099-ls276
      image = "docker.io/linuxserver/radarr@sha256:07a474b61394553e047ad43a1a78c1047fc99be0144c509dd91e3877f402ebcb";
      volumes = [
        "${nas-path}/configs/radarr:/config"
        "${nas-path}:/data"
      ];
    };
  };
}
