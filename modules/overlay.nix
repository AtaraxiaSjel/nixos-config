{ pkgs, config, lib, inputs, ... }:
let
  system = "x86_64-linux";
  old = import inputs.nixpkgs-old ({
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  });
in
{
  nixpkgs.overlays = [
    (self: super:
      rec {
        inherit inputs;

        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        wg-conf = pkgs.callPackage ./packages/wg-conf.nix { };
        i3lock-fancy-rapid = pkgs.callPackage ./packages/i3lock-fancy-rapid.nix { };
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        advance-touch = pkgs.callPackage ./packages/advance-touch.nix { };
        nomino = pkgs.callPackage ./packages/nomino.nix { };
        bpytop = pkgs.callPackage ./packages/bpytop.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        spotifyd = pkgs.callPackage ./packages/spotifyd.nix { };
        # UPDATE
        vivaldi = super.vivaldi.overrideAttrs (old: rec {
          version = "3.6.2165.36-1";
          src = super.fetchurl {
            url = "https://downloads.vivaldi.com/stable/vivaldi-stable_${version}_amd64.deb";
            sha256 = "1wgxzggy5sg98k4lzd34k4hyw2jgc14db41z7s7j3c5whlnifh08";
          };
        });

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
}
