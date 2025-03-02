{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.ataraxia.defaults.lix;
in
{
  options.ataraxia.defaults.lix = {
    enable = mkEnableOption "Enable lix";
  };

  imports = [ inputs.lix-module.nixosModules.default ];

  config.lix.enable = cfg.enable;
}
