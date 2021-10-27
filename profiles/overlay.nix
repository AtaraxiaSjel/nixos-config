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
    # (import "${inputs.nixpkgs-mozilla}/lib-overlay.nix")
    # (import "${inputs.nixpkgs-mozilla}/rust-overlay.nix")
    (self: super:
      rec {
        inherit inputs;

        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        i3lock-fancy-rapid = pkgs.callPackage ./packages/i3lock-fancy-rapid.nix { };
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        ibm-plex-powerline = pkgs.callPackage ./packages/ibm-plex-powerline.nix { };
        bibata-cursors = pkgs.callPackage ./packages/bibata-cursors.nix { };
        multimc = pkgs.qt5.callPackage ./packages/multimc.nix { multimc-repo = inputs.multimc-cracked; };
        ceserver = pkgs.callPackage ./packages/ceserver.nix { };
        mpris-ctl = pkgs.callPackage ./packages/mpris-ctl.nix { };
        tidal-dl = pkgs.callPackage ./packages/tidal-dl.nix { };
        reshade-shaders = pkgs.callPackage ./packages/reshade-shaders.nix { };
        vscode = master.vscode;
        vscode-fhs = master.vscode-fhs;
        vivaldi = master.vivaldi.overrideAttrs (old: rec {
          postInstall = ''
            substituteInPlace "$out"/bin/vivaldi \
              --replace 'vivaldi-wrapped"  "$@"' 'vivaldi-wrapped" --ignore-gpu-blocklist --enable-gpu-rasterization \
              --enable-zero-copy --use-gl=desktop --enable-features=VaapiVideoDecoder --disable-features=UseOzonePlatform "$@"'
          '';
        });
        nix-direnv = inputs.nix-direnv.defaultPackage.${system};
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
        mullvad-vpn = if (versionOlder super.mullvad-vpn.version "2021.5") then super.mullvad-vpn.overrideAttrs (old: rec {
          version = "2021.5";
          src = super.fetchurl {
            url = "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/MullvadVPN-${version}_amd64.deb";
            sha256 = "186va4pllimmcqnlbry5ni8gi8p3mbpgjf7sdspmhy2hlfjvlz47";
          };
          nativeBuildInputs = [ self.makeWrapper ] ++ old.nativeBuildInputs;
          postInstall = ''
            wrapProgram "$out/bin/mullvad-gui" \
              --set MULLVAD_DISABLE_UPDATE_NOTIFICATION 1
          '';
        }) else super.mullvad-vpn;
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };

  home-manager.users.alukard = {
    nixpkgs.config = {
      allowUnfree = true;
    };
    xdg.configFile."nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };
}
