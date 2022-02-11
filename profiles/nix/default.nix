{ config, lib, pkgs, inputs, system,  ... }: {
  nix = rec {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];

    registry.self.flake = inputs.self;
    registry.nixpkgs.flake = inputs.nixpkgs;

    trustedUsers = [ "root" "alukard" "@wheel" ];

    optimise.automatic = true;

    autoOptimiseStore = false;

    package = if !config.deviceSpecific.isServer then
      inputs.nix.defaultPackage.${pkgs.system}.overrideAttrs (oa: {
        patches = [ ./nix.patch ] ++ oa.patches or [ ];
      })
    else pkgs.nixFlakes;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    requireSignedBinaryCaches = true;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
  environment.etc.self.source = inputs.self;
}