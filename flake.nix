{
  description = "System configuration";

  inputs = {
    flake-utils-plus.url = "github:AtaraxiaSjel/flake-utils-plus";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nix.url = "github:nixos/nix";
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:AtaraxiaSjel/impermanence";
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    attic.url = "github:zhaofengli/attic";
    base16.url = "github:AtaraxiaSjel/base16-nix";
    base16-tokyonight-scheme = {
      url = "github:AtaraxiaSjel/base16-tokyonight-scheme";
      flake = false;
    };
    cassowary = {
      url = "github:AtaraxiaSjel/cassowary";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hoyolab-daily-bot = {
      url = "github:AtaraxiaSjel/hoyolab-daily-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-vscode-marketplace = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    prismlauncher.url = "github:AtaraxiaSjel/PrismLauncher/develop";
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
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
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

    patchesPath = map (x: ./patches + "/${x}");
  in flake-utils-plus.lib.mkFlake rec {
    inherit self inputs;
    supportedSystems = [
      "x86_64-linux"
      # "aarch64-linux"
    ];

    customModules = builtins.listToAttrs (findModules ./modules);
    nixosProfiles = builtins.listToAttrs (findModules ./profiles);
    nixosRoles = import ./roles;

    sharedPatches = patchesPath [
      "gitea-208605.patch"
      # "ivpn-ui.patch"
      "ivpn.patch"
      "mullvad-exclude-containers.patch"
      "vaultwarden.patch"
      "webhooks.patch"
      "ydotoold.patch"
    ];
    channelsConfig = { allowUnfree = true; };
    channels.unstable.input = nixpkgs;
    channels.unstable.patches = patchesPath [ "zen-kernels.patch" ] ++ sharedPatches;

    hostDefaults.system = "x86_64-linux";
    hostDefaults.channelName = "unstable";
    hosts = with nixpkgs.lib; let
      hostnames = builtins.attrNames (builtins.readDir ./machines);
      mkHost = name: let
        system = builtins.readFile (./machines + "/${name}/system");
      in {
        inherit system;
        modules = __attrValues self.customModules ++ [
          (import (./machines + "/${name}"))
          { device = name; mainuser = "ataraxia"; }
          inputs.vscode-server.nixosModule
        ];
        specialArgs = { inherit inputs; };
      };
    in (genAttrs hostnames mkHost);

    outputsBuilder = channels: let
      pkgs = channels.unstable;
      # FIXME: nixos-rebuild with --flake flag doesn't work with doas
      rebuild = pkgs.writeShellScriptBin "rebuild" ''
        if [[ -z $1 ]]; then
          echo "Usage: $(basename $0) {switch|boot|test}"
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
      devShells = {
        default = pkgs.mkShell {
          name = "aliases";
          packages = with pkgs; [
            rebuild update-vscode upgrade upgrade-hyprland
            nixfmt nixpkgs-fmt statix vulnix deadnix git
          ];
        };
        ci = pkgs.mkShell {
          name = "ci";
          packages = with pkgs; [
            inputs.attic.packages.${pkgs.system}.attic
            nix-build-uncached
          ];
        };
      };
      packages = {
        Flakes-ISO = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [
            (import (./machines/Flakes-ISO))
            { device = "Flakes-ISO"; mainuser = "ataraxia"; }
            ./machines/Home-Hypervisor/autoinstall.nix
            ./machines/AMD-Workstation/autoinstall.nix
            ./machines/Dell-Laptop/autoinstall.nix
            ./machines/NixOS-VM/autoinstall.nix
            self.customModules.autoinstall
          ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
        Flakes-ISO-Aarch64 = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          modules = [
            (import (./machines/Flakes-ISO))
            { device = "Flakes-ISO"; mainuser = "ataraxia"; }
            ./machines/Arch-Builder-VM/autoinstall.nix
            self.customModules.autoinstall
          ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
        # Build the entire system for uploading to attic
        host-workstation = self.nixosConfigurations."AMD-Workstation".config.system.build.toplevel;
        host-hypervisor = self.nixosConfigurations."Home-Hypervisor".config.system.build.toplevel;
        ivpn-ui = pkgs.callPackage ./profiles/packages/ivpn-ui { };
      };
    };
  };
}
