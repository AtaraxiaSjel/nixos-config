{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.eza;
in
{
  options.ataraxia.programs.eza = {
    enable = mkEnableOption "Enable eza program";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      colors = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
      git = true;
      icons = "auto";
    };
  };
}
