{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.nnn;
in
{
  options.ataraxia.programs.nnn = {
    enable = mkEnableOption "Enable nnn program";
  };

  config = mkIf cfg.enable {
    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override { withNerdIcons = true; };
      # extraPackages = with pkgs; [ ffmpegthumbnailer mediainfo sxiv ];
      # bookmarks = {
      #   d = "~/Documents";
      #   D = "~/Downloads";
      #   p = "~/Pictures";
      #   v = "~/Videos";
      # };
      # plugins = { };
    };

    programs.zsh.shellAliases = {
      "n" = "nnn -deHE";
    };

    persist.state.directories = [
      ".config/nnn"
    ];
  };
}
