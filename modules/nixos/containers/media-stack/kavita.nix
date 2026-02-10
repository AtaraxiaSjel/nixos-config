{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    kavita = mkEnableOption "Enable kavita container";
  };

  config = mkIf cfg.kavita {
    virtualisation.quadlet.containers.kavita = {
      autoStart = true;
      containerConfig = {
        # Tags: 0.8.9, version-v0.8.9.1, v0.8.9.1-ls97
        image = "docker.io/linuxserver/kavita@sha256:ab8d4b81d59ae5c4410bcc1102a7378c72d6cb17a26f350f5fa678b6e376dd3a";
        pod = pods.media-stack.ref;
        environments = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Moscow";
          DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "true";
        };
        volumes = [
          "${nas-path}/configs/kavita:/config"
          "${nas-path}/media/books:/data/books"
          "${nas-path}/media/comics:/data/comics"
          "${nas-path}/media/fanfics:/data/fanfics"
          "${nas-path}/media/manga:/data/manga"
          "${nas-path}/media/novels:/data/novels"
        ];
      };
    };
  };
}
