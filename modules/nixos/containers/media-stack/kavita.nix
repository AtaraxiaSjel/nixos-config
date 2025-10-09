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
        # Tags: 0.8.7, version-v0.8.7, v0.8.7-ls88
        image = "docker.io/linuxserver/kavita@sha256:50f1604a3994c7a31fb413c05829ca9130d73387479e1c1cd3d7c8c4d7d1cc99";
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
