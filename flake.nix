{
  description = "AtaraxiaSjel's NixOS configuration.";

  inputs = {
    devenv.url = "github:cachix/devenv/v2.1.2";
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    ataraxiasjel-builds.url = "github:ataraxiasjel/nix-builds?ref=dev";
    ataraxiasjel-nur = {
      url = "github:AtaraxiaSjel/nur";
      inputs.devenv.follows = "devenv";
      inputs.flake-parts.follows = "flake-parts";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    corecycler.url = "github:Daaboulex/linux-corecycler";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    lmstudio-nix.url = "github:Daaboulex/lmstudio-nix";
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
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zfs-dedup = {
      url = "github:Mic92/zfs-dedup";
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
              inputs.lmstudio-nix.overlays.default
              inputs.nix-cachyos-kernel.overlays.pinned
              inputs.nix-vscode-marketplace.overlays.default
              (final: prev: (import ./overlays inputs) final prev)
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
            blueshift = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            cloverleaf = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            redshift = {
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
                    nixfmt
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
                  nixfmt = default;
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
                vps-default = {
                  fastConnection = false;
                  sshOpts = [
                    "-p"
                    "32323"
                  ];
                };
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
                  cloverleaf = vps-default // {
                    hostname = "panel.ataraxiadev.com";
                  };
                  redshift = vps-default // {
                    hostname = "drive.ataraxiadev.com";
                  };
                  blueshift = vps-default // {
                    hostname = "disk.ataraxiadev.com";
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
