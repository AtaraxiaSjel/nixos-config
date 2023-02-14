{ config, lib, pkgs, inputs,  ... }:
with config.deviceSpecific; {
  nix = rec {
    nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];

    registry.self.flake = inputs.self;
    registry.nixpkgs.flake = inputs.nixpkgs;

    optimise.automatic = true;

    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
      # Prevent Nix from fetching the registry every time
      flake-registry = ${inputs.flake-registry}/flake-registry.json
    '';

    settings = {
      auto-optimise-store = false;
      require-sigs = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://hyprland.cachix.org"
        "https://ataraxiadev-foss.cachix.org"
        # "https://nixos-rocm.cachix.org"
        # "https://webcord.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
        # "nixos-rocm.cachix.org-1:VEpsf7pRIijjd8csKjFNBGzkBqOmw8H9PRmgAq14LnE="
        # "webcord.cachix.org-1:l555jqOZGHd2C9+vS8ccdh8FhqnGe8L78QrHNn+EFEs="
      ];
      trusted-users = [ "root" config.mainuser "@wheel" ];
    };

    buildMachines = [
      {
        hostName = "nix-builder";
        maxJobs = 8;
        sshUser = "alukard";
        sshKey = config.secrets.ssh-builder.decrypted;
        systems = [ "x86_64-linux" "i686-linux" ];
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];

    distributedBuilds = lib.mkIf (config.device != "AMD-Workstation") true;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;
  environment.etc.self.source = inputs.self;

  persist.state.homeDirectories = [ ".local/share/nix" ];
}