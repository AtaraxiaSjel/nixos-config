{ pkgs, config, lib, inputs, ... }:
# let
#   mozilla_overlay = import inputs.nixpkgs-mozilla;
# in
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

        advance-touch = pkgs.callPackage ./applications/advance-touch.nix { };

        nomino = pkgs.callPackage ./applications/nomino.nix { };

        bpytop = pkgs.callPackage ./applications/bpytop.nix { };

        # micro = super.micro.overrideAttrs (old: rec {
        #   version = "2.0.6";
        #   src = inputs.micro;
        # });

        wpgtk = super.wpgtk.overrideAttrs (old: rec {
        	propagatedBuildInputs = with pkgs; [
            python2 python27Packages.pygtk
            python3Packages.pygobject3 python3Packages.pillow python3Packages.pywal
          ];
        });

        discord = super.discord.overrideAttrs (old: rec {
        	version = "0.0.11";
        	src = pkgs.fetchurl {
        		url = "https://dl.discordapp.net/apps/linux/0.0.11/discord-0.0.11.tar.gz";
        		sha256 = "1saqwigi1gjgy4q8rgnwyni57aaszi0w9vqssgyvfgzff8fpcx54";
        	};
        });


        # git-with-libsecret = super.git.override { withLibsecret = true; };

        # spotifyd = super.spotifyd.override { withPulseAudio = true; };

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
