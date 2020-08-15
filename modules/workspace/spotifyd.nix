{ pkgs, config, lib, ... }:
let
  spotifydConf = pkgs.writeText "spotifyd.conf" ''
    [global]
    username = ${config.secrets.spotify.user}
    password = ${config.secrets.spotify.password}
    use_keyring = false
    bitrate = 320
    volume_normalisation = false
    backend = pulseaudio
  '';
in {
  #TODO: отвязать от папки пользователя
  systemd.user.services.spotifyd = {
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" "sound.target" ];
    description = "spotifyd, a Spotify playing daemon";
    serviceConfig = {
      ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --cache-path /home/alukard/.cache/spotifyd --config-path ${spotifydConf}";
      Restart = "always";
      RestartSec = 12;
    };
  };
  # services.spotifyd = {
  #   enable = true;
  #   config = ''
  #   [global]
  #   username = ${config.secrets.spotify.user}
  #   password = ${config.secrets.spotify.password}
  #   use_keyring = false
  #   bitrate = 320
  #   volume_normalisation = false
  #   backend = pulseaudio
  # '';
  # };
}