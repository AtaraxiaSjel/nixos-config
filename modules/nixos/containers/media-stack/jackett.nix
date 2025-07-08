{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    jackett = mkEnableOption "Enable jackett container";
  };

  config = mkIf cfg.jackett {
    virtualisation.oci-containers.containers.jackett = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        TZ = "Europe/Moscow";
      };
      extraOptions = [ "--pod=media-stack" ];
      # Tags: 0.22.2117, version-v0.22.2117, v0.22.2117-ls80
      image = "docker.io/linuxserver/jackett@sha256:221606b0ed7df0d66e601d0ba83f5f9cc9b9c761bafad3507d6854406b3a447b";
      volumes = [
        "${nas-path}/configs/jackett:/config"
      ];
    };
  };
}
