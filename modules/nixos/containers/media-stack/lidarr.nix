{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    lidarr = mkEnableOption "Enable lidarr container";
  };

  config = mkIf cfg.lidarr {
    virtualisation.oci-containers.containers.lidarr = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Europe/Moscow";
      };
      extraOptions = [ "--pod=media-stack" ];
      # Tags: 2.12.4, version-2.12.4.4658, 2.12.4.4658-ls45
      image = "docker.io/linuxserver/lidarr@sha256:71fe6d5702691c6ac8961b9b1042fdea1ff833a49c82c5e165346fa88999a48a";
      volumes = [
        "${nas-path}/configs/lidarr/config:/config"
        "${nas-path}/configs/lidarr/custom-services.d:/custom-services.d"
        "${nas-path}/configs/lidarr/custom-cont-init.d:/custom-cont-init.d"
        "${nas-path}:/data"
      ];
    };
  };
}
