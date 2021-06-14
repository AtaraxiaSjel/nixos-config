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
        bpytop = pkgs.callPackage ./packages/bpytop.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        # spotifyd = pkgs.callPackage ./packages/spotifyd.nix { };
        foliate = pkgs.callPackage ./packages/foliate.nix { };
        vscode = master.vscode;
        vivaldi = master.vivaldi;
        multimc = super.multimc.overrideAttrs (old: rec {
          version = "unstable-2021-04-15";
          src = super.fetchFromGitHub {
            owner = "AfoninZ";
            repo = "MultiMC5-Cracked";
            rev = "22008d9267f9c818bd4b0098e3f0f4a303687b5a";
            sha256 = "9+Hq+0/8HhNURZ3HbJx4ClZgU5pfHl1c7l7wAYFFw1s=";
            fetchSubmodules = true;
          };
        });
        steam = super.steam.override {
          extraLibraries = pkgs: with pkgs; [
            pipewire
          ];
        };
        fontbh100dpi = pkgs.callPackage ({ stdenv, pkg-config, fetchurl, bdftopcf, fontutil, mkfontscale }: stdenv.mkDerivation {
          name = "font-bh-100dpi-1.0.3";
          builder = ./builder.sh;
          src = fetchurl {
            url = "mirror://xorg/individual/font/font-bh-100dpi-1.0.3.tar.bz2";
            sha256 = "10cl4gm38dw68jzln99ijix730y7cbx8np096gmpjjwff1i73h13";
          };
          hardeningDisable = [ "bindnow" "relro" ];
          nativeBuildInputs = [ pkg-config bdftopcf fontutil mkfontscale ];
          buildInputs = [ ];
          preConfigure = ''
            substituteInPlace configure --replace "/bin/sh" "${pkgs.bash}/bin/sh"
          '';
          configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
          meta.platforms = lib.platforms.unix;
        }) {};
        fontbhlucidatypewriter100dpi = super.callPackage ({ stdenv, pkg-config, fetchurl, bdftopcf, fontutil, mkfontscale }: stdenv.mkDerivation {
          name = "font-bh-lucidatypewriter-100dpi-1.0.3";
          builder = ./builder.sh;
          src = fetchurl {
            url = "mirror://xorg/individual/font/font-bh-lucidatypewriter-100dpi-1.0.3.tar.bz2";
            sha256 = "1fqzckxdzjv4802iad2fdrkpaxl4w0hhs9lxlkyraq2kq9ik7a32";
          };
          hardeningDisable = [ "bindnow" "relro" ];
          nativeBuildInputs = [ pkg-config bdftopcf fontutil mkfontscale ];
          buildInputs = [ ];
          preConfigure = ''
            substituteInPlace configure --replace "/bin/sh" "${pkgs.bash}/bin/sh"
          '';
          configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
          meta.platforms = lib.platforms.unix;
        }) {};
        fontbhlucidatypewriter75dpi = super.callPackage ({ stdenv, pkg-config, fetchurl, bdftopcf, fontutil, mkfontscale }: stdenv.mkDerivation {
          name = "font-bh-lucidatypewriter-75dpi-1.0.3";
          builder = ./builder.sh;
          src = fetchurl {
            url = "mirror://xorg/individual/font/font-bh-lucidatypewriter-75dpi-1.0.3.tar.bz2";
            sha256 = "0cfbxdp5m12cm7jsh3my0lym9328cgm7fa9faz2hqj05wbxnmhaa";
          };
          hardeningDisable = [ "bindnow" "relro" ];
          nativeBuildInputs = [ pkg-config bdftopcf fontutil mkfontscale ];
          buildInputs = [ ];
          preConfigure = ''
            substituteInPlace configure --replace "/bin/sh" "${pkgs.bash}/bin/sh"
          '';
          configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
          meta.platforms = lib.platforms.unix;
        }) {};
        # qbittorrent = super.qbittorrent.overrideAttrs (old: rec {
        #   version = "4.3.4.11";
        #   src = super.fetchFromGitHub {
        #     owner = "c0re100";
        #     repo = "qBittorrent-Enhanced-Edition";
        #     # rev = "71404629f86b8b95ea5e4bef9805068678720673";
        #     rev = "release-${version}";
        #     sha256 = "XVjx1fOgNiLGRsvIu0Ny5nai++Mxw4V/uM5zqXCytow=";
        #     fetchSubmodules = true;
        #   };
        # });
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
