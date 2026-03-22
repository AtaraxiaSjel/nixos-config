{
  description = "AtaraxiaSjel's NixOS configuration.";

  inputs = {
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
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
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    ataraxiasjel-builds.url = "github:ataraxiasjel/nix-builds?ref=dev";
    ataraxiasjel-nur = {
      url = "github:AtaraxiaSjel/nur";
      inputs.devenv.follows = "devenv";
      inputs.flake-parts.follows = "flake-parts";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    impermanence.url = "github:nix-community/impermanence";
    lsfg-vk = {
      url = "github:pabloaul/lsfg-vk-flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-index = {
      url = "github:nix-community/nix-index";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-database = {
      url = "github:AtaraxiaSjel/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-vscode-marketplace = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nushell-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };
    prismlauncher.url = "github:AtaraxiaSjel/PrismLauncher";
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
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, withSystem, ... }:
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
            # patches = [ ./patches/erofs-hardened.patch ];
            overlays = [
              inputs.ataraxiasjel-nur.overlays.default
              # inputs.ataraxiasjel-nur.overlays.grub2-unstable-argon2
              inputs.nix-cachyos-kernel.overlays.pinned
              inputs.nix-vscode-marketplace.overlays.default
              (final: prev: (import ./overlays inputs) final prev)
            ];
          };
          importDummyHomeManager = true;
          extraSpecialArgs = {
            flake-self = self;
            secretsDir = ./secrets;
          };
          systemModules = [
            inputs.sops-nix.nixosModules.sops
            inputs.quadlet-nix.nixosModules.quadlet
            ./modules/nixos
          ];
          homeModules = [
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
            # VPS
            quasar = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            cloverleaf = {
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
            ...
          }:
          {
            devenv.shells.default = {
              devenv.root =
                let
                  devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
                in
                lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

              name = "nixos-config";
              packages =
                builtins.attrValues {
                  inherit (pkgs)
                    deploy-rs
                    nixfmt-rfc-style
                    sops
                    ssh-to-age
                    ;
                }
                ++ [ inputs.deploy-rs.packages.${system}.deploy-rs ];
              languages.nix = {
                enable = true;
                lsp.package = pkgs.nixd;
              };
              git-hooks.hooks =
                let
                  default = {
                    enable = true;
                    excludes = [ "secrets/.*" ];
                  };
                in
                {
                  actionlint = default;
                  deadnix = default;
                  # flake-checker = default;
                  markdownlint = default;
                  nixfmt-rfc-style = default;
                  yamlfmt = default;
                  yamllint = default // {
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

        flake = {
          # deploy-rs nodes
          deploy = {
            # default settings for all deploys
            fastConnection = true;
            remoteBuild = false;
            sshUser = "deploy";
            sudo = "doas -u";
            user = "root";
            # nodes for each system
            nodes =
              let
                mkDeploy =
                  {
                    liteConfigNixpkgs,
                    pkgs,
                    system,
                  }:
                  let
                    deployPkgs = import liteConfigNixpkgs {
                      inherit system;
                      overlays = [
                        inputs.deploy-rs.overlays.default
                        (_final: prev: {
                          deploy-rs = {
                            inherit (pkgs) deploy-rs;
                            lib = prev.deploy-rs.lib;
                          };
                        })
                      ];
                    };
                  in
                  name: conf:
                  pkgs.lib.recursiveUpdate {
                    profiles.system = {
                      path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
                    };
                  } conf;
              in
              { }
              // (withSystem "x86_64-linux" (
                {
                  liteConfigNixpkgs,
                  pkgs,
                  system,
                  ...
                }:
                builtins.mapAttrs (mkDeploy { inherit liteConfigNixpkgs pkgs system; }) {
                  orion = {
                    hostname = "orion.lan";
                  };
                  vega = {
                    hostname = "vega.lan";
                  };
                  quasar = {
                    hostname = "drive.ataraxiadev.com";
                    fastConnection = false;
                    sshOpts = [
                      "-p"
                      "32323"
                    ];
                  };
                  cloverleaf = {
                    hostname = "panel.ataraxiadev.com";
                    fastConnection = false;
                    sshOpts = [
                      "-p"
                      "32323"
                    ];
                  };
                }
              ))
              // (withSystem "aarch64-linux" (
                {
                  liteConfigNixpkgs,
                  pkgs,
                  system,
                  ...
                }:
                builtins.mapAttrs (mkDeploy { inherit liteConfigNixpkgs pkgs system; }) {
                  pulsar = {
                    hostname = "pulsar.lan";
                    sudo = "sudo -u";
                  };
                }
              ));
          };

          checks = builtins.mapAttrs (
            _system: deployLib: deployLib.deployChecks self.deploy
          ) inputs.deploy-rs.lib;
        };
      }
    );
}
