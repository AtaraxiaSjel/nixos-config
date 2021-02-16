{ config, lib, pkgs, ... }: {

  home-manager.users.alukard = {
    # xdg.configFile."spicetify/Themes/base16/color.ini".source = ./color.ini;
    # xdg.configFile."spicetify/Themes/base16/user.css".source = ./user.css;
    services.spotifyd = {
      enable = true;
      package = (pkgs.spotifyd.override { withALSA = false; withPulseAudio = true; withPortAudio = false; });
      settings = {
        global = {
          username = "${config.secrets.spotify.user}";
          password = "${config.secrets.spotify.password}";
          backend = "pulseaudio";
          volume_controller = "softvol";
          device_name = "nix";
          bitrate = 320;
          no_audio_cache = true;
          volume_normalisation = false;
          device_type = "computer";
          cache_path = "${config.users.users.alukard.home}/.cache/spotifyd";
        };
      };
    };
  };
}
