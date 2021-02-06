{ config, lib, pkgs, inputs, ... }: {
  nix = rec {
    nixPath = lib.mkForce [ "nixpkgs=/etc/nixpkgs" ];
    binaryCaches = [ "https://cache.nixos.org" ];

    registry.self.flake = inputs.self;

    trustedUsers = [ "root" "alukard" "@wheel" ];

    # nrBuildUsers = 16;

    # optimise.automatic = lib.mkIf (config.device != "Dell-Laptop") true;
    optimise.automatic = true;

    # autoOptimiseStore = config.deviceSpecific.isSSD;
    autoOptimiseStore = false;

    package = pkgs.nixFlakes;
    # package = inputs.nix.packages.x86_64-linux.nix;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    requireSignedBinaryCaches = false;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
}