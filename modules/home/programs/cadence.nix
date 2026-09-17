{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf removePrefix;
  cfg = config.ataraxia.programs.cadence;

  scriptsDir = removePrefix "/" (
    removePrefix config.home.homeDirectory config.services.cadence.settings.scripts_dir
  );
in
{
  imports = [ inputs.cadence.homeManagerModules.default ];

  options.ataraxia.programs.cadence = {
    enable = mkEnableOption "Enable cadence program";
  };

  config = mkIf cfg.enable {
    services.cadence = {
      enable = true;
      settings = {
        scripts_dir = "${config.xdg.configHome}/cadence/scripts";
        default_path =
          lib.makeBinPath (
            with pkgs;
            [
              coreutils
              findutils
              gawk
              gnugrep
              gnused
              python3
            ]
          )
          + ":/run/current-system/sw/bin";
      };
    };

    persist.state.directories = [ scriptsDir ];
  };
}
