{
  description = "System configuration";

  inputs = {
    flake-utils-plus.url = "github:alukardbf/flake-utils-plus/v1.3.1-fix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
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
    # miniguest = {
    #   url = "github:lourkeur/miniguest";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { self, nixpkgs, nixos-generators, flake-utils-plus, ... }@inputs:
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
  in flake-utils-plus.lib.mkFlake {
    inherit self inputs;
    supportedSystems = [ "x86_64-linux" ];

    channelsConfig = { allowUnfree = true; };
    channels.unstable.input = nixpkgs;
    channels.unstable-zfs.input = nixpkgs;
    channels.unstable-zfs.patches = [ ./patches/update-zfs.patch ];

    hostDefaults.system = "x86_64-linux";
    hostDefaults.channelName = "unstable";
    hosts = with nixpkgs.lib; let
      hostnames = builtins.attrNames (builtins.readDir ./machines);
      mkHost = name: {
        system = builtins.readFile (./machines + "/${name}/system");
        modules = [ (import (./machines + "/${name}")) { device = name; } ];
        specialArgs = { inherit inputs; };
      };
    in (genAttrs hostnames mkHost) // {
      AMD-Workstation = {
        system = builtins.readFile (./machines + "/AMD-Workstation/system");
        modules = [ (import (./machines + "/AMD-Workstation")) { device = "AMD-Workstation"; } ];
        specialArgs = { inherit inputs; };
        channelName = "unstable-zfs";
      };
    };

    outputsBuilder = channels: let
      pkgs = channels.unstable;
      rebuild = pkgs.writeShellScriptBin "rebuild" ''
        if [[ -z $1 ]]; then
          echo "Usage: $(basename $0) {switch|boot|test}"
        elif [[ $1 = "iso" ]]; then
          shift
          nix build .#nixosConfigurations.Flakes-ISO.config.system.build.isoImage "$@"
        else
          arg=$1; shift;
          sudo nixos-rebuild $arg --flake . "$@"
        fi
      '';
      update-vscode = pkgs.writeShellScriptBin "update-vscode" ''
        ./scripts/vscode_update_extensions.sh > ./profiles/applications/vscode/extensions.nix
      '';
      upgrade = pkgs.writeShellScriptBin "upgrade" ''
        cp flake.lock flake.lock.bak && nix flake update
        update-vscode
      '';
      upgrade-hyprland = pkgs.writeShellScriptBin "upgrade" ''
        cp flake.lock flake.lock.bak
        nix flake lock --update-input hyprland
      '';
    in {
      devShell = channels.unstable.mkShell {
        name = "aliases";
        packages = [ rebuild update-vscode upgrade upgrade-hyprland ];
      };
      packages = {
        Wayland-VM = nixos-generators.nixosGenerate {
          system = builtins.readFile (./machines/Wayland-VM/system);
          modules = [ (import (./machines/Wayland-VM)) { device = "Wayland-VM"; } ];
          specialArgs = { inherit inputs; };
          format = "vm";
        };
        Testing-VM = nixos-generators.nixosGenerate {
          system = builtins.readFile (./machines/Testing-VM/system);
          modules = [ (import (./machines/Testing-VM)) { device = "Testing-VM"; } ];
          specialArgs = { inherit inputs; };
          format = "vm";
        };
        Flakes-ISO = nixos-generators.nixosGenerate {
          system = builtins.readFile (./machines/Flakes-ISO/system);
          modules = [ (import (./machines/Flakes-ISO)) ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
      };
    };

    nixosModules = builtins.listToAttrs (findModules ./modules);
    nixosProfiles = builtins.listToAttrs (findModules ./profiles);
    nixosRoles = import ./roles;
  };
}
