{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    medusa = mkEnableOption "Enable medusa container";
  };

  config = mkIf cfg.medusa {
    virtualisation.quadlet = {
      builds.medusa = {
        autoStart = true;
        buildConfig = {
          tag = "localhost/pymedusa:develop";
          buildArgs = {
            MEDUSA_RELEASE = "develop";
          };
          workdir = "https://github.com/linuxserver/docker-medusa.git#master";
          # pull = "always";
        };
      };
      containers.medusa = {
        autoStart = true;
        containerConfig = {
          # Tags: 1.0.25, version-v1.0.25, v1.0.25-ls275
          # image = "docker.io/linuxserver/medusa@sha256:472086933262ec7ca33db95f05321a4b7a7d08249e208298f9faf6269aa569e1";
          image = config.virtualisation.quadlet.builds.medusa.ref;
          pod = pods.media-stack.ref;
          environments = {
            PUID = "1000";
            PGID = "100";
            TZ = "Europe/Moscow";
          };
          volumes = [
            "${nas-path}/configs/medusa:/config"
            "${nas-path}:/data"
          ];
        };
      };
    };
    systemd.services.medusa-build.path = [ pkgs.gitMinimal ];
  };
}
