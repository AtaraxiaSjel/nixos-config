{ config, lib, pkgs, inputs, ... }: {
  nix = rec {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
    binaryCaches = [ "https://cache.nixos.org" ];

    registry.self.flake = inputs.self;
    registry.nixpkgs.flake = inputs.nixpkgs;

    trustedUsers = [ "root" "alukard" "@wheel" ];

    # nrBuildUsers = 16;

    # optimise.automatic = lib.mkIf (config.device != "Dell-Laptop") true;
    optimise.automatic = true;

    # autoOptimiseStore = config.deviceSpecific.isSSD;
    autoOptimiseStore = false;

    # package = pkgs.nixFlakes;
    package = inputs.nix.packages.x86_64-linux.nix;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    requireSignedBinaryCaches = true;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
  environment.etc.self.source = inputs.self;
}