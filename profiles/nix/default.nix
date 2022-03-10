{ config, lib, pkgs, inputs, system,  ... }:
with config.deviceSpecific; {
  nix = rec {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];

    registry.self.flake = inputs.self;
    # registry.nixpkgs.flake = if !isContainer then inputs.nixpkgs else inputs.nixpkgs-stable;
    registry.nixpkgs.flake = inputs.nixpkgs;

    optimise.automatic = true;

    package = if !config.deviceSpecific.isServer then
      inputs.nix.defaultPackage.${pkgs.system}.overrideAttrs (oa: {
        patches = [ ./nix.patch ] ++ oa.patches or [ ];
      })
    else pkgs.nixFlakes;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      auto-optimise-store = false;
      require-sigs = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      trusted-users = [ "root" "alukard" "@wheel" ];
    };
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
  # environment.etc.nixpkgs.source = if !isContainer then inputs.nixpkgs else inputs.nixpkgs-stable;
  environment.etc.self.source = inputs.self;
}