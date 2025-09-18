{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.lix;
in
{
  options.ataraxia.defaults.lix = {
    enable = mkEnableOption "Enable lix";
  };

  config = mkIf cfg.enable {
    nix.package = pkgs.lixPackageSets.latest.lix;
  };
}
