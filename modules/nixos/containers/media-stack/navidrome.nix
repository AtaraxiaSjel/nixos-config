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
        # Tags: 2.14.5, version-2.14.5.4836, 2.14.5.4836-ls6
        image = "docker.io/deluan/navidrome:latest";
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
        ];
      };
    };
  };
}
