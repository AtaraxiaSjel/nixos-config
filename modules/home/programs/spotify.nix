{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.spotify;

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options.ataraxia.programs.spotify = {
    enable = mkEnableOption "Enable spotify program";
    spicetify = mkEnableOption "Enable spicetify module" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.spicetify = mkIf cfg.spicetify {
      enable = true;
      experimentalFeatures = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        hidePodcasts
        shuffle
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = if config ? catppuccin then config.catppuccin.flavor else "mocha";
      windowManagerPatch = true;
    };

    home.packages = mkIf (!cfg.spicetify) [
      pkgs.spotifywm
    ];

    defaultApplications.spotify = {
      cmd =
        if cfg.spicetify then
          "${config.programs.spicetify.spicedSpotify}/bin/spotify"
        else
          "${pkgs.spotifywm}/bin/spotify";
      desktop = "spotify";
    };

    startupApplications = [
      config.defaultApplications.spotify.cmd
    ];

    persist.state.directories = [
      ".config/spotify"
    ];
  };
}
