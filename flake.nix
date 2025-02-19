{
  description = "AtaraxiaSjel's NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lite-config.url = "github:ataraxiasjel/lite-config/v0.6.0";
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      {
        imports = [ inputs.lite-config.flakeModule ];

        lite-config = {
          nixpkgs = {
            nixpkgs = inputs.nixpkgs;
            config = { };
            overlays = [ ];
            patches = [ ./patches/onlyoffice.patch ];
            exportOverlayPackages = false;
            setPerSystemPkgs = true;
          };

          systemModules = [ ./modules/nixos ];
          homeModules = [ ./modules/home ];
          hostModuleDir = ./hosts;

          hosts = {
            NixOS-VM.system = "x86_64-linux";
          };
        };

        perSystem = { ... }: { };
      }
    );
}
