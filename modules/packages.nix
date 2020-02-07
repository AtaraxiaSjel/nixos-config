let
  imports = import ../nix/sources.nix;
  mozilla = import imports.nixpkgs-mozilla { };
in { pkgs, config, lib, ... }: {
  nixpkgs.overlays = [
    (self: super:
      rec {
        inherit imports;
        inherit mozilla;

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