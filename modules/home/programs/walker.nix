{
  config,
  lib,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.walker;
in
{
  options.ataraxia.programs.walker = {
    enable = mkEnableOption "Enable walker program";
  };

  config = mkIf cfg.enable {
    defaultApplications.dmenu = {
      cmd = getExe config.services.walker.package;
      desktop = "walker";
    };

    services.walker = {
      enable = true;
      systemd.enable = true;
    };

    services.elephant = {
      enable = true;
    };
  };
}
