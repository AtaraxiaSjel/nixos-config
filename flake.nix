{
  description = "System configuration";

  inputs = {
    flake-utils-plus.url = "github:alukardbf/flake-utils-plus";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-wayland  = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix.url = "github:nixos/nix";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
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
    nix-direnv.url = "github:nix-community/nix-direnv";
    direnv-vscode = {
      url = "github:direnv/direnv-vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-marketplace.url = "github:AmeerTaweel/nix-vscode-marketplace";
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
    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
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
    webcord = {
      url = "github:fufexan/webcord-flake";
      # inputs.nixpkgs.follows = "nixpkgs";
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
    channels.unstable.patches = [ ];
    channels.unstable-zfs.input = nixpkgs;
    channels.unstable-zfs.patches = [ ./patches/zen-kernels.patch ];

    hostDefaults.system = "x86_64-linux";
    hostDefaults.channelName = "unstable";
    hosts = with nixpkgs.lib; let
      hostnames = builtins.attrNames (builtins.readDir ./machines);
      mkHost = name: {
        system = builtins.readFile (./machines + "/${name}/system");
        modules = [ (import (./machines + "/${name}")) { device = name; mainuser = "alukard"; } ];
        specialArgs = { inherit inputs; };
      };
    in (genAttrs hostnames mkHost) // {
      AMD-Workstation = {
        system = builtins.readFile (./machines + "/AMD-Workstation/system");
        modules = [ (import (./machines + "/AMD-Workstation")) { device = "AMD-Workstation"; mainuser = "alukard"; } ];
        specialArgs = { inherit inputs; };
        channelName = "unstable-zfs";
      };
    };

    outputsBuilder = channels: let
      pkgs = channels.unstable;
      pkgs-zfs = channels.unstable-zfs;
      # FIXME: nixos-rebuild with --flakes flag doesn't work with doas
      rebuild = pkgs.writeShellScriptBin "rebuild" ''
        if [[ -z $1 ]]; then
          echo "Usage: $(basename $0) {switch|boot|test}"
        elif [[ $1 = "iso" ]]; then
          shift
          nix build .#nixosConfigurations.Flakes-ISO.config.system.build.isoImage "$@"
        else
          # doas nix-shell -p git --run "nixos-rebuild --flake . $@"
          \sudo nixos-rebuild --flake . $@
        fi
      '';
      update-vscode = pkgs.writeShellScriptBin "update-vscode" ''
        ./scripts/vscode_update_extensions.sh > ./profiles/applications/vscode/extensions.nix
      '';
      upgrade = pkgs.writeShellScriptBin "upgrade" ''
        cp flake.lock flake.lock.bak && nix flake update
        if [[ "$1" == "zfs" ]]; then
          ./scripts/gen-patch-zen.sh
        fi
      '';
      upgrade-hyprland = pkgs.writeShellScriptBin "upgrade-hyprland" ''
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
          modules = [ (import (./machines/Wayland-VM)) { device = "Wayland-VM"; mainuser = "alukard"; } ];
          specialArgs = { inherit inputs; };
          format = "vm";
        };
        Hypervisor-VM = nixos-generators.nixosGenerate {
          system = builtins.readFile (./machines/Hypervisor-VM/system);
          modules = [ (import (./machines/Hypervisor-VM)) { device = "Hypervisor-VM"; mainuser = "alukard"; } ];
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
