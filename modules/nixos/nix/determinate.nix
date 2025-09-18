{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.determinate;
in
{
  options.ataraxia.defaults.determinate = {
    enable = mkEnableOption "Enable Determinate Nix";
  };

  imports = [ inputs.determinate.nixosModules.default ];

  config.determinate.enable = cfg.enable;
  config.nix.settings = mkIf cfg.enable {
    lazy-trees = cfg.enable;
  };
}
