{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard.programs.mpv = {
    enable = true;
    config = {
      vo = "gpu";
      gpu-context = "wayland";
      save-position-on-quit = "yes";
      hwdec = if config.deviceSpecific.devInfo.gpu.vendor == "nvidia" then
        "vdpau"
      else
        "vaapi";
      ytdl-format = if config.deviceSpecific.isLaptop then
        "bestvideo[height<=?1080]+bestaudio/best"
      else
        "bestvideo[height<=?2160]+bestaudio/best";
    };
  };
  # TODO: --cookies-from-browser
  home-manager.users.alukard.home.file.".config/yt-dlp/config" = {
    text = ''
      --cookies=/home/alukard/.config/yt-cookie
      --mark-watched
    '';
  };
}