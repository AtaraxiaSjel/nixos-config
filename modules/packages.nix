{ pkgs, config, lib, ... }:
let
  imports = import ../nix/sources.nix;
  mozilla_overlay = import imports.nixpkgs-mozilla;
in {
  nixpkgs.overlays = [
    mozilla_overlay
    (self: super:
      rec {
        inherit imports;

        youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix { };

        wg-conf = pkgs.callPackage ./applications/wg-conf.nix { };

        i3lock-fancy-rapid = pkgs.callPackage ./applications/i3lock-fancy-rapid.nix { };

        xonar-fp = pkgs.callPackage ./applications/xonar-fp.nix { };

        git-with-libsecret = super.git.override { withLibsecret = true; };
      }
    )
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    spotifyd = pkgs.spotifyd.override { withPulseAudio = true; };
    spotify-tui = pkgs.callPackage ./applications/spotify-tui.nix { };
  };

  nixpkgs.pkgs = import imports.nixpkgs {
    config.allowUnfree = true;
  } // config.nixpkgs.config;

  nix = rec {
    useSandbox = true;
    autoOptimiseStore = config.deviceSpecific.isSSD;
    optimise.automatic = true;
  };
}