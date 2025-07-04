{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.walker;
in
{
  imports = [ inputs.walker.homeManagerModules.default ];

  options.ataraxia.programs.walker = {
    enable = mkEnableOption "Enable walker program";
  };

  config = mkIf cfg.enable {
    defaultApplications.dmenu = {
      cmd = getExe config.programs.walker.package;
      desktop = "walker";
    };

    programs.walker = {
      enable = true;
      package = pkgs.walker;
      runAsService = false;
      config = {
        websearch.prefix = "?";
        switcher.prefix = "/";
      };
    };

    startupApplications = [ "${getExe config.programs.walker.package} --gapplication-service" ];
  };
}
