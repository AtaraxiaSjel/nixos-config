{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.home.packages = with pkgs; [
    spotifywm
  ];
  startupApplications = [
    "${pkgs.spotifywm}/bin/spotifywm"
  ];
}