{ pkgs, ... }: {
  home-manager.users.alukard.programs.ncmpcpp = {
    enable = true;
    # mpdMusicDir = "$HOME/Music";
    settings = {
      mpd_host = "127.0.0.1";
      mpd_port = 6600;
      mpd_music_dir = "$HOME/Music";
    };
  };
}