{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.alacritty;

  inherit (config.theme) fonts;
in
{
  options.ataraxia.programs.alacritty = {
    enable = mkEnableOption "Enable alacritty terminal emulator";
    defaultTerminal = mkEnableOption "Use this terminal emulator by default" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    defaultApplications.term = mkIf cfg.defaultTerminal {
      cmd = getExe pkgs.alacritty;
      desktop = "Alacritty";
    };

    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          decorations = "None";
        };
        font = {
          normal = {
            family = fonts.mono.family;
            style = "Regular";
          };
          size = fonts.size.small;
        };
        cursor = {
          style = {
            shape = "Block";
            blinking = "On";
          };
        };
      };
      # theme = "tokyo_night_enhanced";
    };
  };
}
