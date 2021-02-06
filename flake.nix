{
  description = "System configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    # nixpkgs-old.url = github:nixos/nixpkgs/nixos-20.09;
    nixpkgs-old.url = github:nixos/nixpkgs/nixos-20.09;
    # nix.url = github:nixos/nix/6ff9aa8df7ce8266147f74c65e2cc529a1e72ce0;
    home-manager.url = github:nix-community/home-manager;
    base16.url = github:alukardbf/base16-nix;
    # base16.url = "/media/base16";
    base16-horizon-scheme = {
      url = github:michael-ball/base16-horizon-scheme;
      flake = false;
    };
    materia-theme = {
      url = github:nana-4/materia-theme;
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
    spotify-tui = {
      url = github:Rigellute/spotify-tui;
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
          # pkgs = inputs.nixpkgs.legacyPackages.${system};
          # inherit (inputs.nixpkgs) lib;

          # specialArgsOld = {
          #   inherit inputs;
          # };
          # specialArgs = specialArgsOld // {
          #   inherit name;
          # };

          # hm-nixos-as-super = { config, ... }: {
          #   options.home-manager.users = lib.mkOption {
          #     type = lib.types.attrsOf (lib.types.submoduleWith {
          #       modules = [ ];
          #       specialArgs = specialArgsOld // {
          #         super = config;
          #       };
          #     });
          #   };
          # };

          # modules = [
          #   (import ./default.nix)
          #   inputs.home-manager.nixosModules.home-manager
          #   hm-nixos-as-super
          # ];

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
