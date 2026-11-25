{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.determinate-nix;
in
{
  options.ataraxia.defaults.determinate-nix = {
    enable = mkEnableOption "Enable Determinate Nix";
  };

  config = mkIf cfg.enable {
    nix.package = pkgs.determinate-nix;
    nix.settings = {
      # always-allow-substitutes = true;
      eval-cores = 0;
      lazy-trees = true;
      extra-substituters = [ "https://install.determinate.systems/" ];
      extra-trusted-public-keys = [ "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=" ];
    };
  };
}
