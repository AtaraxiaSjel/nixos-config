{
  description = "AtaraxiaSjel's NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lite-config = {
      url = "github:ataraxiasjel/lite-config/v0.11.1";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    armbian-build = {
      url = "git+https://github.com/armbian/build?rev=a7d6467ca230bc5c0f1ad5d3c55ff64d064bcb08";
      flake = false;
    };
    ataraxiasjel-builds = {
      url = "github:ataraxiasjel/nix-builds?ref=release";
      inputs.nix-cachyos-kernel.inputs.flake-compat.follows = "flake-compat";
      inputs.nix-cachyos-kernel.inputs.flake-parts.follows = "flake-parts";
    };
    ataraxiasjel-nur = {
      url = "github:AtaraxiaSjel/nur?ref=master";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix"; # TODO: follow nixpkgs-unstable
      inputs.flake-parts.follows = "flake-parts";
    };
    lsfg-vk = {
      url = "github:AtaraxiaSjel/lsfg-vk-flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moon-crab = {
      url = "github:AtaraxiaSjel/moon-crab?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index = {
      url = "github:nix-community/nix-index";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-compat.follows = "flake-compat";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-graph = {
      url = "github:AlexAntonik/nix-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-marketplace = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nushell-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    zfs-dedup = {
      url = "github:Mic92/zfs-dedup";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-nanopi-r3s = {
      url = "git+file:///srv/persist/nanopi-nixos/nixos-nanopi-r3s?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      {
        debug = true;

        imports = [
          inputs.git-hooks.flakeModule
          inputs.lite-config.flakeModule
        ];

        lite-config = {
          nixpkgs = {
            nixpkgs = inputs.nixpkgs;
            exportOverlayPackages = false;
            setPerSystemPkgs = true;
            config = {
              allowUnfree = true;
            };
            overlays = [
              inputs.ataraxiasjel-nur.overlays.default
              (
                _final: prev:
                let
                  system = prev.stdenv.hostPlatform.system;
                in
                if system == "x86_64-linux" then inputs.ataraxiasjel-nur.packages.${system} else { }
              )
              inputs.ataraxiasjel-builds.overlays.default
              inputs.nix-vscode-marketplace.overlays.default
              (final: prev: (import ./overlays inputs) final prev)
              (import ./overlays/custom-packages.nix inputs)
            ];
            patches = [
              ./patches/kasmweb-1.19.0.patch
              ./patches/garage-env-export.patch
              # ./patches/incus-containers-only.patch
              ./patches/incus-slim-systemd-path.patch
            ];
          };
          importDummyHomeManager = true;
          extraSpecialArgs = {
            flake-self = self;
            secretsDir = ./secrets;
            customLib = import ./lib { lib = inputs.nixpkgs.lib; };
          };
          systemModules = [
            inputs.sops-nix.nixosModules.sops
            inputs.quadlet-nix.nixosModules.quadlet
            ./modules/nixos
          ];
          homeModules = [
            inputs.sops-nix.homeManagerModules.sops
            inputs.quadlet-nix.homeManagerModules.quadlet
            ./modules/home
          ];
          hostModuleDir = ./hosts;
          hosts = {
            # home-workstation
            andromedae = {
              system = "x86_64-linux";
              useHomeManager = true;
            };
            # dell-laptop
            vega = {
              system = "x86_64-linux";
              useHomeManager = true;
            };
            # home-hypervisor
            orion = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            # incus tuwunel container
            # pulsar = {
            #   system = "aarch64-linux";
            #   useHomeManager = false;
            # };
            # read-only image for writing
            # writer = {
            #   system = "x86_64-linux";
            #   useHomeManager = false;
            # };
            # experimentail nanopi-r3s-lts host
            # tachyon = {
            #   system = "aarch64-linux";
            #   useHomeManager = false;
            # };
            # VPS
            blueshift = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            cloverleaf = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            # matrix = {
            #   system = "x86_64-linux";
            #   useHomeManager = false;
            # };
            redshift = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            cygnus = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            # NixOS-VM = {
            #   system = "x86_64-linux";
            #   useHomeManager = false;
            # };
          };
        };

        perSystem =
          {
            config,
            pkgs,
            lib,
            system,
            inputs',
            ...
          }:
          {
            packages = lib.mkIf (system == "x86_64-linux") (
              let
                tachyonKernel = pkgs.callPackage ./hosts/tachyon/kernel/package.nix {
                  # Pristine upstream set: overlays (cachyos etc.) shadow linux_*.
                  linux_6_18 = inputs'.nixpkgs.legacyPackages.linux_6_18;
                  # Source (non-flake) input: plain `inputs`, not `inputs'`.
                  armbianSrc = inputs.armbian-build;
                };
              in
              {
                tachyon-kernel = tachyonKernel.kernel;
              }
            );
            devShells.default = pkgs.mkShell {
              name = "nixos-config";
              shellHook = config.pre-commit.shellHook;

              NIXD_PATH = "${pkgs.nixd}/bin/nixd";

              packages =
                builtins.attrValues {
                  inherit (pkgs)
                    jq
                    nixd
                    nixfmt
                    sops
                    ssh-to-age
                    ;
                }
                ++ [
                  nixos-rebuild-ng
                  (builtins.attrValues scripts)
                ]
                ++ config.pre-commit.settings.enabledPackages;
            };
            pre-commit.check.enable = false;
            pre-commit.settings = {
              package = pkgs.prek;
              excludes = [ "secrets/.*" ];
              hooks = {
                actionlint.enable = true;
                deadnix.enable = true;
                markdownlint.enable = true;
                nixfmt.enable = true;
                yamlfmt.enable = true;
                yamllint = {
                  enable = true;
                  args = [
                    "--config-file"
                    ".yamllint"
                    "--format"
                    "parsable"
                  ];
                };
              };
            };
          };
      }
    );
}
