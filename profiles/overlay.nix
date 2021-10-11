{ pkgs, config, lib, inputs, ... }:
let
  system = "x86_64-linux";
  stable = import inputs.nixpkgs-stable ({
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  });
  master = import inputs.nixpkgs-master ({
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  });
in
{
  nixpkgs.overlays = [
    # (import "${inputs.nixpkgs-mozilla}/lib-overlay.nix")
    # (import "${inputs.nixpkgs-mozilla}/rust-overlay.nix")
    (self: super:
      rec {
        inherit inputs;

        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        i3lock-fancy-rapid = pkgs.callPackage ./packages/i3lock-fancy-rapid.nix { };
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        multimc = pkgs.qt5.callPackage ./packages/multimc.nix { multimc-repo = inputs.multimc-cracked; };
        ceserver = pkgs.callPackage ./packages/ceserver.nix { };
        mpris-ctl = pkgs.callPackage ./packages/mpris-ctl.nix { };
        tidal-dl = pkgs.callPackage ./packages/tidal-dl.nix { };
        vscode = master.vscode;
        vscode-fhs = master.vscode-fhs;
        vivaldi = master.vivaldi;
        nix-direnv = inputs.nix-direnv.defaultPackage.${system};
        wine = super.wineWowPackages.staging;
        qbittorrent = super.qbittorrent.overrideAttrs (stable: rec {
          version = "enchanced-edition";
          src = inputs.qbittorrent-ee;
        });
        # rust-stable = pkgs.latest.rustChannels.stable.rust.override {
        #   extensions = [
        #     "rls-preview"
        #     "clippy-preview"
        #     "rustfmt-preview"
        #   ];
        # };
        # rust-nightly = pkgs.latest.rustChannels.nightly.rust.override {
        #   extensions = [
        #     "rls-preview"
        #     "clippy-preview"
        #     "rustfmt-preview"
        #   ];
        # };
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };

  home-manager.users.alukard = {
    nixpkgs.config = {
      allowUnfree = true;
    };
    xdg.configFile."nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };
}
