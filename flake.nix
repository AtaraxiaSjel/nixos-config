{
  description = "System configuration";

  inputs = {
    flake-utils-plus.url = "github:alukardbf/flake-utils-plus";
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
    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    base16.url = "github:alukardbf/base16-nix";
    base16-tokyonight-scheme = {
      url = "github:alukardbf/base16-tokyonight-scheme";
      flake = false;
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

    # pkgsFor = system:
    #   import inputs.nixpkgs {
    #     overlays = [ self.overlay ];
    #     localSystem = { inherit system; };
    #     config = {
    #       android_sdk.accept_license = true;
    #     };
    #   };

    patchesPath = map (x: ./patches + "/${x}");
  in flake-utils-plus.lib.mkFlake rec {
    inherit self inputs;
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

    sharedPatches = patchesPath [
      "mullvad-exclude-containers.patch"
      "ydotoold.patch"
      "gitea-208605.patch"
      "waydroid-1.4.0.patch"
      "bitwarden-pr224092.patch"
    ];
    channelsConfig = { allowUnfree = true; };
    channels.unstable.input = nixpkgs;
    channels.unstable.patches = patchesPath [ ] ++ sharedPatches;
    channels.unstable-zfs.input = nixpkgs;
    channels.unstable-zfs.patches = patchesPath [ "zen-kernels.patch" ] ++ sharedPatches;

    hostDefaults.system = "x86_64-linux";
    hostDefaults.channelName = "unstable";
    hosts = with nixpkgs.lib; let
      hostnames = builtins.attrNames (builtins.readDir ./machines);
      mkHost = name: let
        system = builtins.readFile (./machines + "/${name}/system");
        # pkgs = pkgsFor system;
      in {
        inherit system;
        modules = __attrValues self.customModules ++ [
          (import (./machines + "/${name}"))
          # { nixpkgs.pkgs = pkgs; }
          { device = name; mainuser = "ataraxia"; }
          inputs.vscode-server.nixosModule
        ];
        specialArgs = { inherit inputs; };
      };
    in (genAttrs hostnames mkHost) // {
      AMD-Workstation = {
        system = builtins.readFile (./machines/AMD-Workstation/system);
        modules = __attrValues self.customModules ++ [
          (import (./machines/AMD-Workstation))
          { device = "AMD-Workstation"; mainuser = "ataraxia"; }
          inputs.vscode-server.nixosModule
        ];
        specialArgs = { inherit inputs; };
        channelName = "unstable-zfs";
      };
      Flakes-ISO = {
        system = "x86_64-linux";
        modules = __attrValues self.customModules ++ [
          (import (./machines/Flakes-ISO))
          { device = "Flakes-ISO"; mainuser = "ataraxia"; }
          ./machines/Home-Hypervisor/autoinstall.nix
          ./machines/AMD-Workstation/autoinstall.nix
          ./machines/NixOS-VM/autoinstall.nix
        ];
        specialArgs = { inherit inputs; };
      };
      Flakes-ISO-Aarch64 = {
        system = "aarch64-linux";
        modules = __attrValues self.customModules ++ [
          (import (./machines/Flakes-ISO)) { device = "Flakes-ISO-Aarch64"; mainuser = "ataraxia"; }
          ./machines/Arch-Builder-VM/autoinstall.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };

    outputsBuilder = channels: let
      pkgs = channels.unstable;
      pkgs-zfs = channels.unstable-zfs;
      # FIXME: nixos-rebuild with --flake flag doesn't work with doas
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
      devShells.default = channels.unstable.mkShell {
        name = "aliases";
        packages = with pkgs; [
          rebuild update-vscode upgrade upgrade-hyprland
          nixfmt nixpkgs-fmt statix vulnix deadnix
        ];
      };
      packages = {
        Wayland-VM = nixos-generators.nixosGenerate {
          system = builtins.readFile (./machines/Wayland-VM/system);
          modules = __attrValues self.customModules ++ [
            (import (./machines/Wayland-VM))
            { device = "Wayland-VM"; mainuser = "ataraxia"; }
          ];
          specialArgs = { inherit inputs; };
          format = "vm";
        };
        Flakes-ISO = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = __attrValues self.customModules ++ [
            (import (./machines/Flakes-ISO))
            { device = "Flakes-ISO"; mainuser = "ataraxia"; }
            ./machines/Home-Hypervisor/autoinstall.nix
            ./machines/NixOS-VM/autoinstall.nix
          ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
        Flakes-ISO-Aarch64 = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          modules = __attrValues self.customModules ++ [
            (import (./machines/Flakes-ISO))
            { device = "Flakes-ISO-Aarch64"; mainuser = "ataraxia"; }
            ./machines/Arch-Builder-VM/autoinstall.nix
          ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
      };
    };

    customModules = builtins.listToAttrs (findModules ./modules);
    nixosProfiles = builtins.listToAttrs (findModules ./profiles);
    nixosRoles = import ./roles;
  };
}
