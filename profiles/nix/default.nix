{ config, lib, pkgs, inputs, system,  ... }: {
  nix = rec {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nixos-rocm.cachix.org"
      "https://nix-community.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-rocm.cachix.org-1:VEpsf7pRIijjd8csKjFNBGzkBqOmw8H9PRmgAq14LnE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    registry.self.flake = inputs.self;
    registry.nixpkgs.flake = inputs.nixpkgs;

    trustedUsers = [ "root" "alukard" "@wheel" ];

    optimise.automatic = true;

    autoOptimiseStore = false;

    package = inputs.nix.defaultPackage.x86_64-linux.overrideAttrs (oa: {
      patches = [ ./nix.patch ./unset-is-macho.patch ] ++ oa.patches or [ ];
      doInstallCheck = false;
    });

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    requireSignedBinaryCaches = true;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
  environment.etc.self.source = inputs.self;
}