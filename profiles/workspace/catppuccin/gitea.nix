{ cfg, gitea ? "gitea" }: { config, pkgs, lib, ... }:
let
  theme = pkgs.fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v0.4.1/catppuccin-gitea.tar.gz";
    sha256 = "sha256-14XqO1ZhhPS7VDBSzqW55kh6n5cFZGZmvRCtMEh8JPI=";
    stripRoot = false;
  };
in {
  config = lib.mkIf (gitea != "" && config.services.${gitea}.enable) {
    systemd.services.${gitea}.preStart = let
      customDir = config.services.${gitea}.customDir;
      baseDir =
        if lib.versionAtLeast config.services.${gitea}.package.version "1.21.0" then
          "${customDir}/public/assets"
        else
          "${customDir}/public";
    in lib.mkAfter ''
      rm -rf ${baseDir}/css
      mkdir -p ${baseDir}
      ln -sf ${theme} ${baseDir}/css
    '';

    services.${gitea}.settings.ui = {
      DEFAULT_THEME = lib.mkForce "catppuccin-${cfg.flavor}-${cfg.accent}";
      THEMES = let
        builtinThemes = {
          gitea = [
            "auto"
            "gitea"
            "arc-greeen"
          ];
          forgejo = [
            "forgejo-auto"
            "forgejo-light"
            "forgejo-dark"
            "gitea-auto"
            "gitea-light"
            "gitea-dark"
            "forgejo-auto-deuteranopia-protanopia"
            "forgejo-light-deuteranopia-protanopia"
            "forgejo-dark-deuteranopia-protanopia"
            "forgejo-auto-tritanopia"
            "forgejo-light-tritanopia"
            "forgejo-dark-tritanopia"
          ];
        };
      in lib.mkForce builtins.concatStringsSep "," (
        builtinThemes.${gitea}
        ++ (map (name: lib.removePrefix "theme-" (lib.removeSuffix ".css" name)) (
          builtins.attrNames (builtins.readDir theme)
        ))
      );
    };
  };
}