{
  config,
  lib,
  inputs,
  flake-nixpkgs,
  flake-self,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.nix;
in
{
  options.ataraxia.defaults.nix = {
    enable = mkEnableOption "Nix defaults";
  };

  config = mkIf cfg.enable {
    environment.etc.nixpkgs.source = flake-nixpkgs.outPath;
    environment.etc.self.source = flake-self.outPath;
    nix = {
      channel.enable = false;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        # Prevent Nix from fetching the registry every time
        flake-registry = ${inputs.flake-registry}/flake-registry.json
      '';
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 90d";
      };
      registry.ataraxia.flake = flake-self;
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        require-sigs = true;
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://ataraxiadev-foss.cachix.org"
          "https://numtide.cachix.org"
          "https://devenv.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
        trusted-users = [
          "root"
          "deploy"
          "@wheel"
        ];
      };
    };
  };
}
