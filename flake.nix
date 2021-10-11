{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/51bcdc4cdaac48535dabf0ad4642a66774c609ed";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    base16.url = "github:alukardbf/base16-nix";
    base16-horizon-scheme = {
      url = "github:michael-ball/base16-horizon-scheme";
      flake = false;
    };
    base16-tokyonight-scheme = {
      url = "github:alukardbf/base16-tokyonight-scheme";
      flake = false;
    };
    i3lock-fancy-rapid = {
      url = "github:yvbbrjdr/i3lock-fancy-rapid";
      flake = false;
    };
    materia-theme = {
      url = "github:nana-4/materia-theme";
      flake = false;
    };
    multimc-cracked = {
      url = "https://github.com/AfoninZ/MultiMC5-Cracked.git";
      ref = "develop";
      rev = "9069e9c9d0b7951c310fdcc8bdc70ebc422a7634";
      flake = false;
      submodules = true;
      type = "git";
    };
    nixos-rocm = {
      url = "github:nixos-rocm/nixos-rocm/4.3.x";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    nix-direnv = {
      url = "github:nix-community/nix-direnv";
      flake = false;
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    qbittorrent-ee = {
      url = "github:c0re100/qBittorrent-Enhanced-Edition";
      flake = false;
    };
    rycee = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };
    zsh-autosuggestions = {
      url = "github:zsh-users/zsh-autosuggestions";
      flake = false;
    };
    zsh-cod = {
      url = "github:dim-an/cod";
      flake = false;
    };
    zsh-nix-shell = {
      url = "github:chisui/zsh-nix-shell";
      flake = false;
    };
    zsh-you-should-use = {
      url = "github:MichaelAquilina/zsh-you-should-use";
      flake = false;
    };
  };

  outputs = { nixpkgs, nix, self, ... }@inputs:
    let
      findModules = dir:
        builtins.concatLists (builtins.attrValues (builtins.mapAttrs
          (name: type:
            if type == "regular" then
              [{
                name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
                value = dir + "/${name}";
              }]
            else if (builtins.readDir (dir + "/${name}"))
            ? "default.nix" then [{
              inherit name;
              value = dir + "/${name}";
            }] else
              findModules (dir + "/${name}"))
          (builtins.readDir dir)));
    in {
      nixosModules = builtins.listToAttrs (findModules ./modules);

      nixosProfiles = builtins.listToAttrs (findModules ./profiles);

      nixosRoles = import ./roles;
      # Generate system config for each of hardware configuration
      nixosConfigurations = with nixpkgs.lib;
        let
          hosts = builtins.attrNames (builtins.readDir ./machines);
          mkHost = name:
            nixosSystem {
              system = builtins.readFile (./machines + "/${name}/system");
              modules = [ (import (./machines + "/${name}")) { device = name; } ];
              specialArgs = { inherit inputs; };
            };
        in genAttrs hosts mkHost;

      legacyPackages.x86_64-linux =
        (builtins.head (builtins.attrValues self.nixosConfigurations)).pkgs;

      devShell.x86_64-linux = let
        pkgs = self.legacyPackages.x86_64-linux;
        rebuild = pkgs.writeShellScriptBin "rebuild" ''
          if [[ -z $1 ]]; then
            echo "Usage: $(basename $0) {switch|boot|test}"
          elif [[ $1 = "iso" ]]; then
            nix build .#nixosConfigurations.Flakes-ISO.config.system.build.isoImage
          else
            sudo nixos-rebuild $1 --flake .
          fi
        '';
      in pkgs.mkShell {
        nativeBuildInputs = [ rebuild ];
      };
    };
}
