{
  description = "System configuration";

  inputs = {
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    ataraxiasjel-nur.url = "github:AtaraxiaSjel/nur";
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
    deploy-rs.url = "github:serokell/deploy-rs";
    devenv.url = "github:cachix/devenv";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs"; # MESA/OpenGL HW workaround
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mms.url = "github:mkaito/nixos-modded-minecraft-servers";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-marketplace = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur.url = "github:nix-community/NUR";
    prismlauncher.url = "github:AtaraxiaSjel/PrismLauncher/develop";
    rycee = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
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
      "aarch64-linux"
    ];

    customModules = builtins.listToAttrs (findModules ./modules);
    customProfiles = builtins.listToAttrs (findModules ./profiles);
    customRoles = import ./roles;
    secretsDir = ./secrets;

    sharedPatches = patchesPath [
      "rustic-rs-0.7.0.patch"
      "vaultwarden.patch"
      "vscode-1.86.0.patch"
      "webhooks.patch"
    ];
    sharedOverlays = [ flake-utils-plus.overlay inputs.sops-nix.overlays.default ];
    channelsConfig = {
      allowUnfree = true; android_sdk.accept_license = true;
      permittedInsecurePackages = [ "electron-25.9.0" ];
    };
    channels.unstable.input = nixpkgs;
    channels.unstable.patches = patchesPath [ "zfs-unstable-2.2.3.patch" "zen-kernels.patch" "ydotoold.patch" ] ++ sharedPatches;
    channels.stable.input = inputs.nixpkgs-stable;
    channels.stable.patches = sharedPatches;

    hostDefaults.system = "x86_64-linux";
    hostDefaults.channelName = "unstable";
    hosts = with nixpkgs.lib; let
      hostnames =
        filter (n: (builtins.match ".*(ISO|VM)" n) == null)
          (builtins.attrNames (builtins.readDir ./machines));
      mkHost = name: {
        system = builtins.readFile (./machines + "/${name}/system");
        modules = __attrValues self.customModules ++ [
          (import (./machines + "/${name}"))
          { device = name; mainuser = "ataraxia"; }
          inputs.vscode-server.nixosModule
          inputs.sops-nix.nixosModules.sops
        ];
        specialArgs = { inherit inputs; };
      };
    in (genAttrs hostnames mkHost) // {
      Home-Hypervisor = {
        system = builtins.readFile (./machines/Home-Hypervisor/system);
        modules = __attrValues self.customModules ++ [
          (import (./machines/Home-Hypervisor))
          { device = "Home-Hypervisor"; mainuser = "ataraxia"; }
          inputs.vscode-server.nixosModule
          inputs.sops-nix.nixosModules.sops
        ];
        specialArgs = { inherit inputs; };
        channelName = "unstable";
      };
      NixOS-VPS = {
        system = builtins.readFile (./machines/NixOS-VPS/system);
        modules = [
          (import (./machines/NixOS-VPS))
          { device = "NixOS-VPS"; mainuser = "ataraxia"; }
          inputs.sops-nix.nixosModules.sops
        ];
        specialArgs = { inherit inputs; };
        channelName = "stable";
      };
    };

    nixosHostsCI = builtins.listToAttrs (map (name: {
        inherit name;
        value = self.nixosConfigurations."${name}".config.system.build.toplevel;
      }) (builtins.attrNames self.nixosConfigurations));

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
            nixfmt-rfc-style nixpkgs-fmt statix vulnix deadnix git deploy-rs
            fup-repl ssh-to-pgp sops
          ];
        };
        ci = pkgs.mkShell {
          name = "ci";
          packages = with pkgs; [
            nix-eval-jobs jq
          ];
        };
        sops = pkgs.mkShell {
          name = "sops";
          sopsPGPKeyDirs = [
            "${toString ./.}/keys/hosts"
            "${toString ./.}/keys/users"
          ];
          sopsCreateGPGHome = true;
          packages = with pkgs; [ ssh-to-pgp sops sops-import-keys-hook ];
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
            self.customModules.autoinstall
          ];
          specialArgs = { inherit inputs; };
          format = "install-iso";
        };
      };
    };

    deploy.nodes = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      pkgs-arm = import nixpkgs { system = "aarch64-linux"; };
      deployPkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          inputs.deploy-rs.overlay
          (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
      };
      deployPkgs-arm = import nixpkgs {
        system = "aarch64-linux";
        overlays = [
          inputs.deploy-rs.overlay
          (self: super: { deploy-rs = { inherit (pkgs-arm) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
      };
      mkDeploy = name: conf: {
        profiles.system = {
          sshUser = "deploy";
          user = "root";
          fastConnection = true;
          remoteBuild = false;
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
        };
      } // conf;
      mkDeploy-arm = name: conf: {
        profiles.system = {
          sshUser = "deploy";
          user = "root";
          fastConnection = true;
          remoteBuild = true;
          path = deployPkgs-arm.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
        };
      } // conf;
    in builtins.mapAttrs mkDeploy {
      Home-Hypervisor = { hostname = "192.168.0.10"; };
      Dell-Laptop = { hostname = "192.168.0.101"; };
      NixOS-VPS = { hostname = "nixos-vps"; };
    } // builtins.mapAttrs mkDeploy-arm {
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
