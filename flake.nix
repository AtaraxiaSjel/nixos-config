{
  description = "System configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows ="nixpkgs";
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
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    umu = {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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
        nixosSystem = n: import (n + "/nixos/lib/eval-config.nix");
        # Make host config
        mkHost = name: nixosSystem: self-nixpkgs:
          nixosSystem {
            system = builtins.readFile (./machines + "/${name}/system");
            modules = builtins.attrValues self.customModules ++ [
              (import (./machines + "/${name}"))
              { device = name; mainuser = "ataraxia"; }
              { nixpkgs.config.allowUnfree = true; }
              { sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; }
              inputs.sops-nix.nixosModules.sops
              inputs.lix-module.nixosModules.default
            ];
            specialArgs = { inherit self inputs self-nixpkgs; secretsDir = ./secrets; };
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
                self.customModules.autoinstall
              ];
              specialArgs = { inherit inputs; };
              format = "install-iso";
            };
          };
        };

        flake = let
          unstable-nixpkgs = nixpkgs-patched inputs.nixpkgs unstable-patches;
          stable-nixpkgs = nixpkgs-patched inputs.nixpkgs-stable stable-patches;
          unstable-system = nixosSystem unstable-nixpkgs;
          stable-system = nixosSystem stable-nixpkgs;

          shared-patches = patchesPath [ ];
          unstable-patches = shared-patches ++ patchesPath [
            "366250.patch"
            # "netbird-24.11.patch"
            "onlyoffice.patch"
            # "zen-kernels.patch"
          ];
          stable-patches = shared-patches ++ patchesPath [
            # "netbird-24.05.patch"
          ];
        in {
          customModules = builtins.listToAttrs (findModules ./modules);
          customProfiles = builtins.listToAttrs (findModules ./profiles);
          customRoles = import ./roles;
          secretsDir = ./secrets;
          inherit unstable-nixpkgs;

          nixosConfigurations = withSystem "x86_64-linux" ({ ... }:
            {
              AMD-Workstation = mkHost "AMD-Workstation" unstable-system unstable-nixpkgs;
              Dell-Laptop     = mkHost "Dell-Laptop"     unstable-system unstable-nixpkgs;
              Home-Hypervisor = mkHost "Home-Hypervisor" unstable-system unstable-nixpkgs;
              NixOS-VPS       = mkHost "NixOS-VPS"       stable-system   stable-nixpkgs;
              NixOS-RO-VPS    = mkHost "NixOS-RO-VPS"    stable-system   stable-nixpkgs;
            }
          );

          packages.x86_64-linux = {
            NixOS-VM = inputs.nixos-generators.nixosGenerate {
              system = "x86_64-linux";
              modules = builtins.attrValues self.customModules ++ [
                (import (./machines/NixOS-VM))
                { device = "NixOS-VM"; mainuser = "ataraxia"; }
                { nixpkgs.config.allowUnfree = true; }
                inputs.sops-nix.nixosModules.sops
              ];
              specialArgs = {
                inherit self inputs;
                secrets = ./secrets;
                self-nixpkgs = unstable-nixpkgs;
              };
              nixosSystem = unstable-system;
              format = "vm";
            };
          };

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
                  sudo = "doas -u";
                  fastConnection = true;
                  remoteBuild = false;
                  path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
                };
              } // conf;
            in builtins.mapAttrs mkDeploy {
              Home-Hypervisor = { hostname = "10.10.10.10"; };
              Dell-Laptop = { hostname = "10.10.10.101"; };
              NixOS-VPS = { hostname = "45.135.180.193"; };
              NixOS-RO-VPS = { hostname = "45.134.48.174"; };
            }
          );

          checks = builtins.mapAttrs (system: deployLib:
            deployLib.deployChecks self.deploy
          ) inputs.deploy-rs.lib;
        };
      }
  );
}
