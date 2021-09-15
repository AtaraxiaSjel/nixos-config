{ config, lib, pkgs, inputs, ... }: {
  nix = rec {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
    binaryCaches = [ "https://cache.nixos.org" ];

    registry.self.flake = inputs.self;
    registry.nixpkgs.flake = inputs.nixpkgs;

    trustedUsers = [ "root" "alukard" "@wheel" ];

    optimise.automatic = true;

    autoOptimiseStore = false;

    package = inputs.nix.packages.x86_64-linux.nix.overrideAttrs (oa: {
      patches = [./nix.patch] ++ oa.patches or [];
    });

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    requireSignedBinaryCaches = true;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
  environment.etc.self.source = inputs.self;
}