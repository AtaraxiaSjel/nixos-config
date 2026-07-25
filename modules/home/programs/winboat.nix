{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.winboat;
in
{
  options.ataraxia.programs.winboat = {
    enable = mkEnableOption "Enable winboat program";
  };

  config = mkIf cfg.enable {
    # home.packages = [ pkgs.winboat ];
    persist.state.directories = [
      ".config/winboat"
      ".winboat"
      ".winboat-img"
      "winboat-shared"
    ];
  };
}
