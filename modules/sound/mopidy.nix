{ pkgs, config, lib, ... }: {
  # TODO: FIXIT!
  services.mopidy = {
    enable = true;
    # extensionPackages = with pkgs; [ mopidy-gmusic mopidy-youtube ];
    configuration = ''
      [mpd]
      hostname = 0.0.0.0
      [audio]
      output = pulsesink server=127.0.0.1
      [local]
      enabled = true
      library = json
      media_dir = /home/alukard/Music
      scan_timeout = 1000
      scan_flush_threshold = 100
      scan_follow_symlinks = false
    '';
  };

  systemd.services.mopidy = {
    after = [ "network-online.target" ];
  };

  # users.users.mopidy = {
  #   isNormalUser = false;
  #   extraGroups = [
  #     "smbgrp"
  #   ];
  # };
  # services.mopidy = {
  #   enable = true;
  #   # extensionPackages = with pkgs; [ mopidy-local ];
  #   configuration = ''
  #     [local]
  #     enabled = true
  #     library = json
  #     media_dir = /home/alukard/Music
  #     scan_timeout = 1000
  #     scan_flush_threshold = 100
  #     scan_follow_symlinks = false

  #     [audio]
  #     output = pulsesink server=127.0.0.1

  #     [mpd]
  #     hostname = 0.0.0.0
  #   '';
  # };
  # home-manager.users.alukard.home.file.".ncmpcpp/config".text = ''
  #   mpd_host = 127.0.0.1
  #   mpd_port = 6600
  #   mpd_music_dir = "/media/files/Music"
  # '';

}