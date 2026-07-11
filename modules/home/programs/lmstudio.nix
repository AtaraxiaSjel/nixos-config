{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.lmstudio;
in
{
  options.ataraxia.programs.lmstudio = {
    enable = mkEnableOption "Enable lmstudio program";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lmstudio ];
    persist.state.directories = [ ".lmstudio" ];
  };
}
