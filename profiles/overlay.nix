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
    (import "${inputs.nixpkgs-mozilla}/rust-overlay.nix")
    (self: super:
      rec {
        inherit inputs;

        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        wg-conf = pkgs.callPackage ./packages/wg-conf.nix { };
        i3lock-fancy-rapid = pkgs.callPackage ./packages/i3lock-fancy-rapid.nix { };
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        advance-touch = pkgs.callPackage ./packages/advance-touch.nix { };
        nomino = pkgs.callPackage ./packages/nomino.nix { };
        # bpytop = pkgs.callPackage ./packages/bpytop.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        foliate = pkgs.callPackage ./packages/foliate.nix { };
        vscode = master.vscode;
        vscode-fhs = master.vscode-fhs;
        vivaldi = master.vivaldi;
        multimc = pkgs.qt5.callPackage ./packages/multimc.nix { multimc-repo = inputs.multimc-cracked; };
        nix-direnv = inputs.nix-direnv.defaultPackage.${system};
        steam = super.steam.override {
          extraLibraries = pkgs: with pkgs; [
            pipewire
          ];
        };
        wine = super.wineWowPackages.staging;
        qbittorrent = super.qbittorrent.overrideAttrs (stable: rec {
          version = "enchanced-edition";
          src = inputs.qbittorrent-ee;
        });
        rust-stable = pkgs.latest.rustChannels.stable.rust.override {
          extensions = [
            "rls-preview"
            "clippy-preview"
            "rustfmt-preview"
          ];
        };
        rust-nightly = pkgs.latest.rustChannels.nightly.rust.override {
          extensions = [
            "rls-preview"
            "clippy-preview"
            "rustfmt-preview"
          ];
        };
        # material-icons = pkgs.callPackage ./packages/material-icons-inline.nix { };
        # wpgtk = super.wpgtk.overrideAttrs (stable: rec {
        # 	propagatedBuildInputs = with pkgs; [
        #     python2 python27Packages.pygtk
        #     python3Packages.pygobject3 python3Packages.pillow python3Packages.pywal
        #   ];
        # });
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
