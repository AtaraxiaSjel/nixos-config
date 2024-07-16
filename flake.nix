{
  description = "System configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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
    # ataraxiasjel-nur.url = "/home/ataraxia/projects/nur";
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
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc.url = "github:catppuccin/vscode";
    deploy-rs.url = "github:serokell/deploy-rs";
    devenv.url = "github:cachix/devenv";
    disko = {
      url = "github:nix-community/disko";
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
    prismlauncher.url = "github:AtaraxiaSjel/PrismLauncher/develop";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (
    { self, inputs, withSystem, ... }:
      let
        findModules = dir:
          builtins.concatLists (
            builtins.attrValues (
              builtins.mapAttrs (name: type:
                if type == "regular" then [
                  {
                    name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
                    value = dir + "/${name}";
                  }
                ] else if (builtins.readDir (dir + "/${name}")) ? "default.nix" then [
                  {
                    inherit name;
                    value = dir + "/${name}";
                  }
                ]
                else findModules (dir + "/${name}")
              ) (builtins.readDir dir)
            )
          );

        # Patch nixpkgs
        nixpkgs-patched = n: p:
          (import n { system = "x86_64-linux"; }).pkgs.applyPatches {
            name = if n ? shortRev then "nixpkgs-patched-${n.shortRev}" else "nixpkgs-patched";
            src = n;
            patches = p;
          };
        # Get nixosSystem func from patched nixpkgs
        nixosSystem = n: p: import ((nixpkgs-patched n p) + "/nixos/lib/eval-config.nix");
        # Make host config
        mkHost = name: nixosSystem:
          nixosSystem {
            system = builtins.readFile (./machines + "/${name}/system");
            modules = builtins.attrValues self.customModules ++ [
              (import (./machines + "/${name}"))
              { device = name; mainuser = "ataraxia"; }
              { nixpkgs.config.allowUnfree = true; }
              inputs.sops-nix.nixosModules.sops
            ];
            specialArgs = { inherit self; inherit inputs; secrets = ./secrets; };
          };

        patchesPath = map (x: ./patches + "/${x}");
      in {
        imports = [ ];
        systems = [ "x86_64-linux" ];

        perSystem = { pkgs, self', ... }: {
          devShells.default = let
            rebuild = pkgs.writeShellScriptBin "rebuild" ''
              [[ -n "$1" ]] && doas nixos-rebuild --flake . $@
            '';
            upgrade = pkgs.writeShellScriptBin "upgrade" ''
              cp flake.lock flake.lock.bak && nix flake update
              [[ "$1" == "zfs" ]] && ./scripts/gen-patch-zen.sh
            '';
          in pkgs.mkShell {
            name = "aliases";
            packages = [
              rebuild upgrade
            ] ++ builtins.attrValues {
              inherit (pkgs) nixfmt-rfc-style statix deadnix git deploy-rs sops;
            };
          };

          packages = {
            Flakes-ISO = inputs.nixos-generators.nixosGenerate {
              system = "x86_64-linux";
              modules = [
                (import (./machines/Flakes-ISO))
                { device = "Flakes-ISO"; mainuser = "ataraxia"; }
                ./machines/AMD-Workstation/autoinstall.nix
                ./machines/Dell-Laptop/autoinstall.nix
                ./machines/Home-Hypervisor/autoinstall.nix
                self.customModules.autoinstall
              ];
              specialArgs = { inherit inputs; };
              format = "install-iso";
            };
          };
        };

        flake = let
          unstable = nixosSystem inputs.nixpkgs unstable-patches;
          stable = nixosSystem inputs.nixpkgs-stable stable-patches;

          shared-patches = patchesPath [ ];
          unstable-patches = shared-patches ++ patchesPath [
                "jaxlib.patch"
            "netbird-24.11.patch"
            "onlyoffice.patch"
            "vaultwarden.patch"
            # "zen-kernels.patch"
            "fix-args-override.patch"
          ];
          stable-patches = shared-patches ++ patchesPath [ "netbird-24.05.patch" "vaultwarden-24.05.patch" ];
        in {
          customModules = builtins.listToAttrs (findModules ./modules);
          customProfiles = builtins.listToAttrs (findModules ./profiles);
          customRoles = import ./roles;
          secretsDir = ./secrets;
          nixpkgs-unstable-patched = nixpkgs-patched inputs.nixpkgs unstable-patches;

          nixosConfigurations = withSystem "x86_64-linux" ({ ... }:
            {
              AMD-Workstation = mkHost "AMD-Workstation" unstable;
              Dell-Laptop =     mkHost "Dell-Laptop" unstable;
              Home-Hypervisor = mkHost "Home-Hypervisor" unstable;
              NixOS-VPS =       mkHost "NixOS-VPS" stable;
              NixOS-VM =        mkHost "NixOS-VM" unstable;
            }
          );

          deploy.nodes = withSystem "x86_64-linux" ({ ... }:
            let
              pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
              deployPkgs = import inputs.nixpkgs {
                system = "x86_64-linux";
                overlays = [
                  inputs.deploy-rs.overlay
                  (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
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
            in builtins.mapAttrs mkDeploy {
              Home-Hypervisor = { hostname = "192.168.0.10"; };
              Dell-Laptop = { hostname = "192.168.0.101"; };
              NixOS-VPS = { hostname = "83.138.55.118"; };
            }
          );

          checks = builtins.mapAttrs (system: deployLib:
            deployLib.deployChecks self.deploy
          ) inputs.deploy-rs.lib;
        };
      }
  );
}
