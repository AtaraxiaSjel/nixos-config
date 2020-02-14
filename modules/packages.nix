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

        # naersk = pkgs.callPackage pkgs.imports.naersk {};

        youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix { };

        wg-conf = pkgs.callPackage ./applications/wg-conf.nix { };

        i3lock-fancy-rapid = pkgs.callPackage ./applications/i3lock-fancy-rapid.nix { };

        xonar-fp = pkgs.callPackage ./applications/xonar-fp.nix { };

        git-with-libsecret = super.git.override { withLibsecret = true; };

        spotifyd = super.spotifyd.override { withPulseAudio = true; };

        spicetify-cli = pkgs.callPackage ./applications/spicetify-cli.nix { };

        # spotify-tui = pkgs.callPackage ./applications/spotify-tui.nix { };

        # spotify-tui = naersk.buildPackage {
        #   name = "spotify-tui";
        #   src = pkgs.imports.spotify-tui;
        #   buildInputs = [ pkgs.pkgconf pkgs.openssl ];
        # };

        # mopidy = super.mopidy.overridePythonAttrs (oa: {
        #   src = imports.mopidy;
        #   propagatedBuildInputs = with self.python27Packages; [
        #     gst-python
        #     pygobject3
        #     pykka
        #     tornado_4
        #     requests
        #     setuptools
        #     dbus-python
        #     protobuf
        #   ];
        # });
      }
    )
  ];

  # nixpkgs.config.packageOverrides = pkgs: {
  #   spotifyd = pkgs.spotifyd.override { withPulseAudio = true; };
  #   spotify-tui = pkgs.callPackage ./applications/spotify-tui.nix { };
  # };

  nixpkgs.pkgs = import imports.nixpkgs {
    config.allowUnfree = true;
  } // config.nixpkgs.config;

  nix = rec {
    useSandbox = true;
    autoOptimiseStore = config.deviceSpecific.isSSD;
    optimise.automatic = true;
    # Change nixpkgs path to niv source
    nixPath = [
      "nixpkgs=${imports.nixpkgs}"
      "nixos-config=/etc/nixos/configuration.nix"
      # "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };
}