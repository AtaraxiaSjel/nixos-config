{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.containers.media-stack;
  pods = config.virtualisation.quadlet.pods;

  nas-path = "/media/nas/media-stack";
in
{
  options.ataraxia.containers.media-stack = {
    navidrome = mkEnableOption "Enable navidrome container";
  };

  config = mkIf cfg.navidrome {
    virtualisation.quadlet.containers.navidrome = {
      autoStart = true;
      containerConfig = {
        # Tags: 0.62.0
        image = "docker.io/deluan/navidrome@sha256:c4b5cb36a790b3eb63ca6a68bbe2fe149c2d7fa2e586f7a480e61db630e6664b";
        pod = pods.media-stack.ref;
        environments = {
          # ND_BASEURL = "https://music.ataraxiadev.com";
          ND_BASEURL = "";
          ND_MUSICFOLDER = "/music/managed"; # Default library path
          ND_ENABLEINSIGHTSCOLLECTOR = "false";
          ND_REVERSEPROXYUSERHEADER = "Remote-User";
          ND_REVERSEPROXYWHITELIST = "0.0.0.0/0";
          ND_ENABLEUSEREDITING = "true";
          # ND_ENABLEUSEREDITING = "false";
        };
        user = "1000:100";
        volumes = [
          "${nas-path}/configs/navidrome:/data"
          "${nas-path}/media/music:/music/managed:ro"
          "${nas-path}/media/music-unsorted:/music/unmanaged:ro"
          "${nas-path}/media/soulseek/downloads:/music/slsk-downloads:ro"
          "${nas-path}/media/soulseek/share:/music/slsk-share:ro"
        ];
      };
    };
  };
}
