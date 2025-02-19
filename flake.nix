{
  description = "AtaraxiaSjel's NixOS configuration.";

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lite-config.url = "github:ataraxiasjel/lite-config/v0.6.0";
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "file+file:///dev/null";
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
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          inputs.devenv.flakeModule
          inputs.lite-config.flakeModule
        ];

        lite-config = {
          nixpkgs = {
            nixpkgs = inputs.nixpkgs;
            config = { };
            overlays = [ ];
            patches = [ ./patches/onlyoffice.patch ];
            exportOverlayPackages = false;
            setPerSystemPkgs = true;
          };

          systemModules = [ ./modules/nixos ];
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
                inherit (pkgs) nixfmt-rfc-style git sops;
              };
              pre-commit.hooks = {
                actionlint.enable = true;
                deadnix.enable = true;
                flake-checker.enable = true;
                lychee.enable = true;
                markdownlint.enable = true;
                nixfmt-rfc-style.enable = true;
                ripsecrets.enable = true;
                # statix.enable = true;
                typos.enable = true;
                yamlfmt.enable = true;
                yamllint.enable = true;
              };
              # https://github.com/cachix/devenv/issues/528
              containers = { };
            };
          };
      }
    );
}
