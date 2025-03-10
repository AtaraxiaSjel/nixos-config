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
    lix-module = {
      # url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      url = "github:ataraxiasjel/lix-nixos-module/2.92.0-1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
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
                inherit (pkgs) nixfmt-rfc-style sops;
              };
              languages.nix = {
                enable = true;
                lsp.package = pkgs.nixd;
              };
              pre-commit.hooks = {
                actionlint.enable = true;
                deadnix.enable = true;
                flake-checker.enable = true;
                lychee.enable = true;
                lychee.args = [
                  "--exclude"
                  "^https://.+\\.backblazeb2\\.com"
                ];
                markdownlint.enable = true;
                nixfmt-rfc-style.enable = true;
                ripsecrets.enable = true;
                # statix.enable = true;
                typos.enable = true;
                yamlfmt.enable = true;
                yamllint.enable = true;
                yamllint.args = [
                  "--config-file"
                  ".yamllint"
                  "--format"
                  "parsable"
                ];
              };
            };
          };
      }
    );
}
