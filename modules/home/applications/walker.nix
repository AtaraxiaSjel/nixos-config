{
  config,
  lib,
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
      runAsService = true;
      elephant = {
        providers = [
          "calc"
          "clipboard"
          "desktopapplications"
          # "files" # files provider starts very slowly
          "menus"
          "providerlist"
          "runner"
          "symbols"
          "todo"
          "unicode"
          "websearch"
        ];
      };
    };
  };
}
