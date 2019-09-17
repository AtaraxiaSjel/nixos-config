{ config, lib, pkgs, ... }:
with rec {
  inherit (config) deviceSpecific;
};
with deviceSpecific; {
  home-manager.users.alukard.programs.mpv = {
    enable = true;
    config = {
      ytdl-format = if isLaptop then
        "bestvideo[height<=?1080]+bestaudio/best"
      else
        "bestvideo+bestaudio/best";
      # cache-default = 4000000;
    };
  };
}