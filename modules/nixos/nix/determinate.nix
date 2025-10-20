{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.determinate;

  jsonFormat = pkgs.formats.json { };
in
{
  options.ataraxia.defaults.determinate = {
    enable = mkEnableOption "Enable Determinate Nix";
  };

  imports = [ inputs.determinate.nixosModules.default ];

  config.determinate.enable = cfg.enable;
  config.nix.settings = mkIf cfg.enable {
    eval-cores = 0;
  };
  config.environment.etc."determinate/config.json" = mkIf cfg.enable {
    source = jsonFormat.generate "determinate-config" {
      garbageCollector = {
        strategy = "disabled";
      };
    };
  };
}
