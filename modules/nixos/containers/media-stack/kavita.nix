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
        # Tags: 0.8.6, version-v0.8.6.2, v0.8.6.2-ls79
        image = "docker.io/linuxserver/kavita@sha256:b222e4b2137db2301756d018076d0bfee858077d8af24d709f1f4003d628e580";
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
