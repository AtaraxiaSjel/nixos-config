{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.eza;

  catpuccin-theme = pkgs.fetchurl {
    url = "https://github.com/eza-community/eza-themes/raw/7465d04d9834f94b56943024354cf61d2e67efe4/themes/catppuccin.yml";
    hash = "sha256-Db7QrlhhU7rZk2IVVfGGRS5JEue6itBzoa77pmKE7EI=";
  };
in
{
  options.ataraxia.programs.eza = {
    enable = mkEnableOption "Enable eza program";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      colors = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
      git = true;
      icons = "auto";
      # TODO: change in catpuccin theme module, not here
      theme = catpuccin-theme;
    };
  };
}
