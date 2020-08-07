{
  description = "System configuration";

  inputs = {
    # nixpkgs = github:nixos/nixpkgs-channels/840c782d507d60aaa49aa9e3f6d0b0e780912742;
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    home-manager.url = github:rycee/home-manager/bqv-flakes;
    base16-horizon-scheme = {
      url = github:AlukardBF/base16-horizon-scheme;
      flake = false;
    };
    materia-theme = {
      url = github:nana-4/materia-theme;
      flake = false;
    };
    zsh-autosuggestions = {
      url = github:zsh-users/zsh-autosuggestions;
      flake = false;
    };
    zsh-nix-shell = {
      url = github:chisui/zsh-nix-shell;
      flake = false;
    };
    zsh-you-should-use = {
      url = github:MichaelAquilina/zsh-you-should-use;
      flake = false;
    };
    i3lock-fancy-rapid = {
      url = github:yvbbrjdr/i3lock-fancy-rapid;
      flake = false;
    };
    spotify-tui = {
      url = github:Rigellute/spotify-tui;
      flake = false;
    };
    nixpkgs-mozilla = {
      url = github:mozilla/nixpkgs-mozilla;
      flake = false;
    };
  };

  # outputs = inputs@{ nixpkgs, ... }: {
  #   nixosConfigurations.NixOS-VM =
  #   let
  #     name = "NixOS-VM";
  #   in nixpkgs.lib.nixosSystem {
  #     modules = [ (import ./default.nix) ];
  #     # Select the target system here.
  #     system = "x86_64-linux";
  #     specialArgs = { inherit inputs name; };
  #   };
  # };

  outputs = { nixpkgs, nix, self, ... }@inputs: {
    nixosConfigurations = with nixpkgs.lib;
      let
        hosts = map (fname: builtins.head (builtins.match "(.*)\\.nix" fname))
          (builtins.attrNames (builtins.readDir ./hardware-configuration));
        mkHost = name:
          nixosSystem {
            system = "x86_64-linux";
            modules = [ (import ./default.nix) ];
            specialArgs = { inherit inputs name; };
          };
      in genAttrs hosts mkHost;

    legacyPackages.x86_64-linux =
      (builtins.head (builtins.attrValues self.nixosConfigurations)).pkgs;

    # nix run github:serokell/deploy
    # Because sudo requires local presence of my Yubikey, we have to manually activate the system
    # sudo nix-env -p /nix/var/nix/profiles/system --set /nix/var/nix/profiles/per-user/alukard/system;
    # sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    deploy = {
      user = "alukard";
      nodes = builtins.mapAttrs (_: conf: {
        hostname = conf.config.networking.hostName;
        profiles.system.path = conf.config.system.build.toplevel;
      }) self.nixosConfigurations;
    };
  };
}
