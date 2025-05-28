{
  description = "AtaraxiaSjel's NixOS configuration.";

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

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

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lite-config.url = "github:ataraxiasjel/lite-config/v0.8.0";
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ataraxiasjel-nur.url = "github:AtaraxiaSjel/nur";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, withSystem, ... }:
      {
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
            patches = [ ./patches/erofs-hardened.patch ];
            overlays = [
              inputs.ataraxiasjel-nur.overlays.default
              inputs.ataraxiasjel-nur.overlays.grub2-unstable-argon2
              (final: prev: (import ./overlays inputs) final prev)
            ];
          };
          extraSpecialArgs = {
            flake-self = self;
            secretsDir = ./secrets;
          };
          systemModules = [
            inputs.sops-nix.nixosModules.sops
            ./modules/nixos
          ];
          homeModules = [ ./modules/home ];
          hostModuleDir = ./hosts;
          hosts = {
            NixOS-VM.system = "x86_64-linux";
            # home-hypervisor
            orion = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
            # VPS
            redshift = {
              system = "x86_64-linux";
              useHomeManager = false;
            };
          };
        };

        perSystem =
          { pkgs, lib, ... }:
          {
            devenv.shells.default = {
              devenv.root =
                let
                  devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
                in
                lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

              name = "nixos-config";
              packages = builtins.attrValues {
                inherit (pkgs) deploy-rs nixfmt-rfc-style sops;
              };
              languages.nix = {
                enable = true;
                lsp.package = pkgs.nixd;
              };
              pre-commit.hooks =
                let
                  default = {
                    enable = true;
                    excludes = [ "secrets/.*" ];
                  };
                in
                {
                  actionlint = default;
                  deadnix = default;
                  flake-checker = default;
                  lychee = default // {
                    args = [
                      "--exclude-all-private"
                      "--exclude"
                      "^https://.*\\.backblazeb2\\.com"
                      "--exclude"
                      "^https://.*\\.ataraxiadev\\.com"
                    ];
                  };
                  markdownlint = default;
                  nixfmt-rfc-style = default;
                  ripsecrets = default;
                  typos = default;
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
            nodes = withSystem "x86_64-linux" (
              {
                liteConfigNixpkgs,
                pkgs,
                ...
              }:
              let
                # take advantage of the nixpkgs binary cache
                deployPkgs = import liteConfigNixpkgs {
                  system = "x86_64-linux";
                  overlays = [
                    inputs.deploy-rs.overlay
                    (_final: prev: {
                      deploy-rs = {
                        inherit (pkgs) deploy-rs;
                        lib = prev.deploy-rs.lib;
                      };
                    })
                  ];
                };
                mkDeploy =
                  name: conf:
                  pkgs.lib.recursiveUpdate {
                    profiles.system = {
                      path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
                    };
                  } conf;
              in
              builtins.mapAttrs mkDeploy {
                orion = {
                  hostname = "10.10.10.10";
                };
                redshift = {
                  hostname = "104.164.54.197";
                  fastConnection = false;
                  sshOpts = [
                    "-p"
                    "32323"
                  ];
                };
              }
            );
          };

          checks = builtins.mapAttrs (
            _system: deployLib: deployLib.deployChecks self.deploy
          ) inputs.deploy-rs.lib;
        };
      }
    );
}
