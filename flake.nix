{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-custom.url = "github:nixos/nixpkgs/894bced14f7c66112d39233bcaeaaf708e077759";
    nixpkgs-wayland  = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix.url = "github:nixos/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    base16.url = "github:alukardbf/base16-nix";
    base16-tokyonight-scheme = {
      url = "github:alukardbf/base16-tokyonight-scheme";
      flake = false;
    };
    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    nur.url = github:nix-community/NUR;
    polymc = {
      url = "github:AquaVirus/PolyMC-Cracked";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qbittorrent-ee = {
      url = "github:c0re100/qBittorrent-Enhanced-Edition";
      flake = false;
    };
    rycee = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server-fixup = {
      url = "github:MatthewCash/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zsh-autosuggestions = {
      url = "github:zsh-users/zsh-autosuggestions";
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

  outputs = { self, nixpkgs, nixpkgs-stable, ... }@inputs:
    let
      rebuild = (pkgs: pkgs.writeShellScriptBin "rebuild" ''
        if [[ -z $1 ]]; then
          echo "Usage: $(basename $0) {switch|boot|test}"
        elif [[ $1 = "iso" ]]; then
          nix build .#nixosConfigurations.Flakes-ISO.config.system.build.isoImage
        else
          sudo nixos-rebuild $1 --flake .
        fi
      '');
      update-vscode = (pkgs: pkgs.writeShellScriptBin "update-vscode" ''
        ./scripts/vscode_update_extensions.sh > ./profiles/applications/vscode/extensions.nix
      '');
      upgrade = (pkgs: pkgs.writeShellScriptBin "upgrade" ''
        cp flake.lock flake.lock.bak && nix flake update
        update-vscode
      '');
      upgrade-hyprland = (pkgs: pkgs.writeShellScriptBin "upgrade" ''
        cp flake.lock flake.lock.bak
        nix flake lock --update-input hyprland
      '');
      refresh-hyprland = (pkgs: pkgs.writeShellScriptBin "refresh-hyprland" ''
        rm -f ~/.config/hypr/hyprland.conf
        rebuild test
        cp ~/.config/hypr/hyprland.conf ~/.config/hypr/1
        rm -f ~/.config/hypr/hyprland.conf
        cp ~/.config/hypr/1 ~/.config/hypr/hyprland.conf
        rm -f ~/.config/hypr/1
        systemctl stop --user gammastep.service
      '');
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
          mkHost = name: nixosSystem {
            system = builtins.readFile (./machines + "/${name}/system");
            modules = [ (import (./machines + "/${name}")) { device = name; } ];
            specialArgs = { inherit inputs; };
          };
        in (genAttrs hosts mkHost) // {
          # NixOS-CT = nixpkgs-stable.lib.nixosSystem {
          #   system = builtins.readFile (./machines/NixOS-CT/system);
          #   modules = [ (import (./machines/NixOS-CT)) { device = "NixOS-CT"; } ];
          #   specialArgs = { inherit inputs; };
          # };
        };

      legacyPackages.x86_64-linux =
        (builtins.head (builtins.attrValues self.nixosConfigurations)).pkgs;

      devShell.x86_64-linux = let
        pkgs = self.legacyPackages.x86_64-linux;
      in pkgs.mkShell {
        nativeBuildInputs = [ (rebuild pkgs) (update-vscode pkgs) (upgrade pkgs) (upgrade-hyprland pkgs) (refresh-hyprland pkgs)];
      };
    };
}
