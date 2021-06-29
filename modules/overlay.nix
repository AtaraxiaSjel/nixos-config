{ pkgs, config, lib, inputs, ... }:
let
  system = "x86_64-linux";
  old = import inputs.nixpkgs-old ({
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
        vivaldi = master.vivaldi;
        multimc = super.multimc.overrideAttrs (old: rec {
          version = "unstable-cracked";
          src = super.fetchFromGitHub {
            owner = "AfoninZ";
            repo = "MultiMC5-Cracked";
            rev = "6d6218a21ba54e77c4fc76b3ae8cddf3334f1a5d";
            sha256 = "0k59pnqdlzqp75c1lbpqy2i09mmy5qisikalm427i16b07ga9xcl";
            fetchSubmodules = true;
          };
        });
        steam = super.steam.override {
          extraLibraries = pkgs: with pkgs; [
            pipewire
          ];
        };
        wine = super.wineWowPackages.staging;
        qbittorrent = super.qbittorrent.overrideAttrs (old: rec {
          version = "4.3.6.10";
          src = super.fetchFromGitHub {
            owner = "c0re100";
            repo = "qBittorrent-Enhanced-Edition";
            rev = "release-${version}";
            sha256 = "1pfwg95vi1yig36qkganhqw1rz28qfzlfpixnbb3hibvzsjl2p8m";
          };
        });
        rust-stable = pkgs.latest.rustChannels.stable.rust.override {
          extensions = [
            "rls-preview"
            "clippy-preview"
            "rustfmt-preview"
          ];
        };
        # material-icons = pkgs.callPackage ./packages/material-icons-inline.nix { };
        # wpgtk = super.wpgtk.overrideAttrs (old: rec {
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

  home-manager.users.alukard.xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
