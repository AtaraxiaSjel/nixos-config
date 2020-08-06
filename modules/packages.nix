{ pkgs, config, lib, inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.nix.overlay
    # mozilla_overlay
    (self: super:
      rec {
        inherit inputs;

        youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix { };

        wg-conf = pkgs.callPackage ./applications/wg-conf.nix { };

        i3lock-fancy-rapid = pkgs.callPackage ./applications/i3lock-fancy-rapid.nix { };

        xonar-fp = pkgs.callPackage ./applications/xonar-fp.nix { };

        # git-with-libsecret = super.git.override { withLibsecret = true; };

        # spotifyd = super.spotifyd.override { withPulseAudio = true; };

        # tlp = pkgs.callPackage ./applications/tlp { };

        # spotify-tui = pkgs.callPackage ./applications/spotify-tui.nix { };

        # spotify-tui = naersk.buildPackage {
        #   name = "spotify-tui";
        #   src = pkgs.imports.spotify-tui;
        #   buildInputs = [ pkgs.pkgconf pkgs.openssl ];
        # };
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.etc.nixpkgs.source = inputs.nixpkgs;

  nix = rec {
    useSandbox = true;

    autoOptimiseStore = config.deviceSpecific.isSSD;

    optimise.automatic = true;

    nixPath = lib.mkForce [
      "nixpkgs=/etc/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # TODO: change?
    # package = pkgs.nixFlakes;
    package = inputs.nix.packages.x86_64-linux.nix;

    registry.self.flake = inputs.self;
  };
}
