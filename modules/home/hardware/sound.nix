{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.defaults.sound;
in
{
  options.ataraxia.defaults.sound = {
    enable = mkEnableOption "Default sound settings";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol
      pulseaudio
    ];
    services.easyeffects.enable = true;

    persist.state.directories = [ ".local/state/wireplumber" ];
  };
}
