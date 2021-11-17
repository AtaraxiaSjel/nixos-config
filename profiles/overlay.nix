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
with lib; {
  nixpkgs.overlays = [
    inputs.android-nixpkgs.overlay
    inputs.nixpkgs-wayland.overlay
    (self: super:
      rec {
        inherit inputs;

        android-emulator = self.callPackage ./packages/android-emulator.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        ceserver = pkgs.callPackage ./packages/ceserver.nix { };
        i3lock-fancy-rapid = pkgs.callPackage ./packages/i3lock-fancy-rapid.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        mpris-ctl = pkgs.callPackage ./packages/mpris-ctl.nix { };
        multimc = pkgs.qt5.callPackage ./packages/multimc.nix { multimc-repo = inputs.multimc-cracked; };
        reshade-shaders = pkgs.callPackage ./packages/reshade-shaders.nix { };
        tidal-dl = pkgs.callPackage ./packages/tidal-dl.nix { };
        vscode = master.vscode;
        vscode-fhs = master.vscode-fhs;
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        vivaldi = master.vivaldi;
        wine = super.wineWowPackages.staging;
        qbittorrent = super.qbittorrent.overrideAttrs (old: rec {
          version = "enchanced-edition";
          src = inputs.qbittorrent-ee;
        });
        btrbk = if (versionOlder super.btrbk.version "0.32.0") then super.btrbk.overrideAttrs (old: rec {
          version = "0.32.0-master";
          src = super.fetchFromGitHub {
            owner = "digint";
            repo = "btrbk";
            rev = "cb38b7efa411f08fd3d7a65e19a8cef385eda0b8";
            sha256 = "sha256-426bjK7EDq5LHb3vNS8XYnAuA6TUKXNOVrjGMR70bio=";
          };
          preFixup = ''
            wrapProgram $out/bin/btrbk \
              --set PERL5LIB $PERL5LIB \
              --run 'export program_name=$0' \
              --prefix PATH ':' "${with self; lib.makeBinPath [ btrfs-progs bash mbuffer openssh ]}"
          '';
        }) else super.btrbk;
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
