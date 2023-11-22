{ config, lib, inputs, ... }: {
  nix = {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
    registry.self.flake = inputs.self;
    registry.nixpkgs.flake = inputs.nixpkgs;
    optimise.automatic = lib.mkDefault true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
      flake-registry = ${inputs.flake-registry}/flake-registry.json
    '';
    settings = {
      auto-optimise-store = false;
      require-sigs = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://ataraxiadev-foss.cachix.org"
        "https://cache.ataraxiadev.com/ataraxiadev"
        "https://numtide.cachix.org"
        "https://devenv.cachix.org"
        "https://ezkea.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
        "ataraxiadev:/V5bNjSzHVGx6r2XA2fjkgUYgqoz9VnrAHq45+2FJAs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      ];
      trusted-users = [ "root" config.mainuser "@wheel" ];
    };
  };
  environment.etc.nixpkgs.source = inputs.nixpkgs;
  environment.etc.self.source = inputs.self;
}
