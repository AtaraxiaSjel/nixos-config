{ config, lib, pkgs, ... }:
with rec {
  inherit (config) deviceSpecific;
};
with deviceSpecific; {
  home-manager.users.alukard.programs.mpv = {
    enable = true;
    config = {
      vo = "gpu";
      hwdec = if video == "nvidia" then
        "vdpau"
      else
        "vaapi";
      ytdl-format = if isLaptop then
        "bestvideo[height<=?1080]+bestaudio/best"
      else
        "bestvideo+bestaudio/best";
    };
  };
  # TODO: отвязать от /home/alukard
  home-manager.users.alukard.home.file.".config/youtube-dl/config" = {
    text = ''
      --cookie=/home/alukard/.config/yt-cookie
      --mark-watched
    '';
  };
}