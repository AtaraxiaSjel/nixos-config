{
  description = "System configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-master.url = github:nixos/nixpkgs/master;
    nixpkgs-old.url = github:nixos/nixpkgs/nixos-20.09;
    nix.url = github:NixOS/nix/8a5203d3b836497c2c5f157f85008aa8bcb6a1d2;
    home-manager.url = github:nix-community/home-manager;
    base16.url = github:alukardbf/base16-nix;
    base16-horizon-scheme = {
      url = github:michael-ball/base16-horizon-scheme;
      flake = false;
    };
    base16-material-ocean-scheme = {
      url = "/home/alukard/projects/base16-material-ocean-scheme";
      flake = false;
    };
    materia-theme = {
      url = github:nana-4/materia-theme/3e2220a133746a7fc80b0f995a40ffda55443de0;
      flake = false;
    };
    zsh-autosuggestions = {
      url = github:zsh-users/zsh-autosuggestions;
      flake = false;
    };
    zsh-nix-shell = {
      url = github:chisui/zsh-nix-shell;
      flake = false;
    };
    zsh-you-should-use = {
      url = github:MichaelAquilina/zsh-you-should-use;
      flake = false;
    };
    zsh-cod = {
      url = github:dim-an/cod;
      flake = false;
    };
    i3lock-fancy-rapid = {
      url = github:yvbbrjdr/i3lock-fancy-rapid;
      flake = false;
    };
    nixpkgs-mozilla = {
      url = github:mozilla/nixpkgs-mozilla;
      flake = false;
    };
  };

  outputs = { nixpkgs, nix, self, ... }@inputs: {
    nixosModules = import ./modules;

    nixosProfiles = import ./profiles;
    # Generate system config for each of hardware configuration
    nixosConfigurations = with nixpkgs.lib;
      let
        hosts = builtins.attrNames (builtins.readDir ./machines);
        mkHost = name: let
          system = builtins.readFile (./machines + "/${name}/system");
          modules = [ (import (./machines + "/${name}")) { device = name; } ];
          specialArgs = { inherit inputs; };
        in nixosSystem { inherit system modules specialArgs; };
      in genAttrs hosts mkHost;

    legacyPackages.x86_64-linux =
      (builtins.head (builtins.attrValues self.nixosConfigurations)).pkgs;

    devShell.x86_64-linux = let
      pkgs = self.legacyPackages.x86_64-linux;
      rebuild = pkgs.writeShellScriptBin "rebuild" ''
        if [[ -z $1 ]]; then
          echo "Usage: $(basename $0) {switch|boot|test}"
        else
          sudo nixos-rebuild $1 --flake .
        fi
      '';
    in pkgs.mkShell {
      nativeBuildInputs = [ rebuild ];
    };
  };
}
