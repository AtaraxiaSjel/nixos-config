{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.spotifyd-user;
  tomlFormat = pkgs.formats.toml { };
  configFile = tomlFormat.generate "spotifyd.conf" cfg.settings;
in {
  options.services.spotifyd-user = {
    enable = mkEnableOption "SpotifyD connect";

    package = mkOption {
      type = types.package;
      default = pkgs.spotifyd;
      defaultText = literalExample "pkgs.spotifyd";
      example =
        literalExample "(pkgs.spotifyd.override { withKeyring = true; })";
      description = ''
        The <literal>spotifyd</literal> package to use.
        Can be used to specify extensions.
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Configuration for spotifyd";
      example = literalExample ''
        {
          global = {
            username = "Alex";
            password = "foo";
            device_name = "nix";
          };
        }
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users.alukard.home.packages = [ cfg.package ];

      systemd.user.services.spotifyd = {
        description = "spotify daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" "sound.target" ];
        partOf = [ "pulseeffects.service" ];
        serviceConfig = {
          ExecStart =
            "${cfg.package}/bin/spotifyd --no-daemon --config-path ${configFile}";
          Restart = "always";
          RestartSec = 12;
        };
      };
    })
    {
      secrets.spotify = {
        owner = "alukard";
        services = [ "spotifyd" ];
      };

      services.spotifyd-user = {
        enable = true;
        package = (pkgs.spotifyd.override { withALSA = false; withPulseAudio = true; withPortAudio = false; });
        settings = {
          global = {
            username = "alukard.files@gmail.com";
            password_cmd = "${pkgs.coreutils}/bin/cat ${config.secrets.spotify.decrypted}";
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
    }
  ];
}
# {

#   home-manager.users.alukard = {
#     # xdg.configFile."spicetify/Themes/base16/color.ini".source = ./color.ini;
#     # xdg.configFile."spicetify/Themes/base16/user.css".source = ./user.css;
#     services.spotifyd = {
#       enable = true;
#       package = (pkgs.spotifyd.override { withALSA = false; withPulseAudio = true; withPortAudio = false; });
#       settings = {
#         global = {
#           username = "${config.secrets.spotify.user}";
#           password = "${config.secrets.spotify.password}";
#           backend = "pulseaudio";
#           volume_controller = "softvol";
#           device_name = "nix";
#           bitrate = 320;
#           no_audio_cache = true;
#           volume_normalisation = false;
#           device_type = "computer";
#           cache_path = "${config.users.users.alukard.home}/.cache/spotifyd";
#         };
#       };
#     };
#   };
# }
