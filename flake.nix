{
  description = "System configuration";

  inputs = {
    flake-utils-plus.url = "github:alukardbf/flake-utils-plus";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
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
    prism-launcher.url = "github:AtaraxiaSjel/PrismLauncher/develop";
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

  outputs = { self, nixpkgs, nixos-generators, flake-utils-plus, deploy-rs, ... }@inputs:
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
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

    sharedPatches = patchesPath [ "mullvad-exclude-containers.patch" "gitea-208605.patch" ];
    channelsConfig = { allowUnfree = true; };
    channels.unstable.input = nixpkgs;
    channels.unstable.patches = patchesPath [ ] ++ sharedPatches;
    channels.unstable-zfs.input = nixpkgs;
    channels.unstable-zfs.patches = patchesPath [ "zen-kernels.patch" ] ++ sharedPatches;

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
        system = builtins.readFile (./machines/AMD-Workstation/system);
        modules = [ (import (./machines/AMD-Workstation)) { device = "AMD-Workstation"; mainuser = "alukard"; } ];
        specialArgs = { inherit inputs; };
        channelName = "unstable-zfs";
      };
      Home-Hypervisor = {
        system = builtins.readFile (./machines/Home-Hypervisor/system);
        modules = [ (import (./machines/Home-Hypervisor)) { device = "Home-Hypervisor"; mainuser = "ataraxia"; } ];
        specialArgs = { inherit inputs; };
      };
      Flakes-ISO = {
        system = "x86_64-linux";
        modules = [
          (import (./machines/Flakes-ISO)) { device = "Flakes-ISO"; mainuser = "alukard"; }
          ./machines/Home-Hypervisor/autoinstall.nix
          ./machines/NixOS-VM/autoinstall.nix
        ];
        specialArgs = { inherit inputs; };
      };
      Flakes-ISO-Aarch64 = {
        system = "aarch64-linux";
        modules = [
          (import (./machines/Flakes-ISO)) { device = "Flakes-ISO-Aarch64"; mainuser = "alukard"; }
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
          modules = [ (import (./machines/Wayland-VM)) { device = "Wayland-VM"; mainuser = "alukard"; } ];
          specialArgs = { inherit inputs; };
          format = "vm";
        };
        Flakes-ISO = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [
            (import (./machines/Flakes-ISO)) { device = "Flakes-ISO"; mainuser = "alukard"; }
            ./machines/Home-Hypervisor/autoinstall.nix
            ./machines/NixOS-VM/autoinstall.nix
          ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
        Flakes-ISO-Aarch64 = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          modules = [
            (import (./machines/Flakes-ISO)) { device = "Flakes-ISO-Aarch64"; mainuser = "alukard"; }
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

    deploy = {
      user = "root";
      sudo = "doas -u";
      fastConnection = true;
      sshOpts = [ "-A" ];
      # nodes.Hypervisor-VM = {
      #   hostname = "192.168.122.63";
      #   profiles = {
      #     system = {
      #       user = "root";
      #       sshUser = "alukard";
      #       path =
      #         deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.Hypervisor-VM;
      #     };
      #   };
      # };
    };

    # deploy = {
    #   user = "root";
    #   nodes = (builtins.mapAttrs (name: machine:
    #     let activateable = name == "T420-Laptop" || name == "RasPi-Server";
    #     in {
    #       hostname = machine.config.networking.hostName;
    #       profiles.system = {
    #         user = if activateable then "root" else "alukard";
    #         path = with deploy-rs.lib.${machine.pkgs.system}.activate;
    #           if activateable then
    #             nixos machine
    #           else
    #             noop machine.config.system.build.toplevel;
    #       };
    #     }) self.nixosConfigurations);
    # };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
