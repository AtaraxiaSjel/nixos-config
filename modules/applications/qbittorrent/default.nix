{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard = {
    home.file.".config/qBittorrent/darkstylesheet.qbtheme" = {
      source = ./darkstylesheet.qbtheme;
    };
  };
}