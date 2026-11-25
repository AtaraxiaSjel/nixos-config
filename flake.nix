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
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    armbian-build = {
      url = "git+https://github.com/armbian/build?rev=a7d6467ca230bc5c0f1ad5d3c55ff64d064bcb08";
      flake = false;
    };

    arkivist = {
      url = "git+https://git.ataraxiadev.com/ataraxiadev/arkivist?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ataraxiasjel-builds.url = "github:ataraxiasjel/nix-builds?ref=dev";
    ataraxiasjel-nur = {
      url = "github:AtaraxiaSjel/nur";
      inputs.devenv.follows = "devenv";
      inputs.flake-parts.follows = "flake-parts";
    };
    cadence = {
      url = "git+https://git.ataraxiadev.com/ataraxiadev/cadence?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    corecycler.url = "github:Daaboulex/linux-corecycler";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher";
    hyprland.url = "github:hyprwm/Hyprland";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "";
      inputs.home-manager.follows = "";
    };
    lsfg-vk = {
      url = "github:pabloaul/lsfg-vk-flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-index = {
      url = "github:nix-community/nix-index";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nushell-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    quadpin = {
      url = "git+https://git.ataraxiadev.com/ataraxiadev/quadpin.git?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
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
          inputs.devenv.flakeModule
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
              inputs.nix-cachyos-kernel.overlays.pinned
              inputs.nix-vscode-marketplace.overlays.default
              (final: prev: (import ./overlays inputs) final prev)
              (import ./overlays/custom-packages.nix inputs)
            ];
            patches = [
              ./patches/kasmweb-1.19.0.patch
              ./patches/garage-env-export.patch
              ./patches/incus-containers-only.patch
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
            pulsar = {
              system = "aarch64-linux";
              useHomeManager = false;
            };
            # read-only image for writing
            writer = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            # experimentail nanopi-r3s-lts host
            tachyon = {
              system = "aarch64-linux";
              useHomeManager = false;
            };
            # VPS
            blueshift = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            cloverleaf = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            matrix = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            redshift = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            cygnus = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            NixOS-VM = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
          };
        };

        perSystem =
          {
            pkgs,
            lib,
            system,
            inputs',
            ...
          }:
          {
            # Phase 6: tachyon custom kernel, cross-built x86_64 -> aarch64.
            # Trial package only, NOT wired into any system yet.
            # Sources: armbian-build input (pinned commit); our delta is
            # hosts/tachyon/kernel/delta-v1.conf. No IFD, no vendored files.
            # NOTE: manualConfig drv has outputs out/dev/modules; .config for
            # intent-vs-result diffs via `nix build '.#...tachyon-kernel^dev'`.
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
