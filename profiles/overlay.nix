{ pkgs, config, lib, inputs, ... }:
let
  inherit (pkgs) system;
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
    inputs.nixpkgs-wayland.overlay
    inputs.nix-alien.overlay
    (self: super:
      rec {
        inherit inputs;

        android-emulator = self.callPackage ./packages/android-emulator.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        ceserver = pkgs.callPackage ./packages/ceserver.nix { };
        gamescope = pkgs.callPackage ./packages/gamescope.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        kitti3 = pkgs.python3Packages.callPackage ./packages/kitti3.nix { };
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
        pass-secret-service = super.pass-secret-service.overrideAttrs (_: { installCheckPhase = null; });
        qbittorrent = super.qbittorrent.overrideAttrs (old: rec {
          version = "enchanced-edition";
          src = inputs.qbittorrent-ee;
        });
        btrbk = if (versionOlder super.btrbk.version "0.32.0") then super.btrbk.overrideAttrs (old: rec {
          version = "0.32.0-master";
          src = super.fetchFromGitHub {
            owner = "digint";
            repo = "btrbk";
            rev = "c5273a8745fa60fc52b3180fa210ec3048e6a419";
            sha256 = "sha256-Q5KIndnXtTJmqVjmuucutWPggLey7ceT9sqeEInC8vw=";
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
