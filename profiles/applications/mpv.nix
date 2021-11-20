{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard.programs.mpv = {
    enable = true;
    config = {
      vo = "gpu";
      hwdec = if config.deviceSpecific.devInfo.gpu.vendor == "nvidia" then
        "vdpau"
      else
        "vaapi";
      ytdl-format = if config.deviceSpecific.isLaptop then
        "bestvideo[height<=?1080]+bestaudio/best"
      else
        "bestvideo+bestaudio/best";
    };
  };
  home-manager.users.alukard.home.file.".config/youtube-dl/config" = {
    text = ''
      --cookie=/var/secrets/yt-cookie
      --mark-watched
    '';
  };

  secrets.yt-cookie = {
    owner = "alukard";
  };
}