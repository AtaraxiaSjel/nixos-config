{
  config,
  lib,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.zathura;
in
{
  options.ataraxia.programs.zathura = {
    enable = mkEnableOption "Enable zathura program";
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
    };

    defaultApplications.document-viewer = {
      cmd = getExe config.programs.zathura.package;
      desktop = "zathura";
    };
  };
}
