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
}