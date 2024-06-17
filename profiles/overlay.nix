{ pkgs, config, lib, inputs, ... }:
let
  inherit (pkgs.hostPlatform) system;
  master = import inputs.nixpkgs-master {
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  };
  stable = import inputs.nixpkgs-stable {
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  };
  # nur = import inputs.nur {
  #   nurpkgs = import inputs.nixpkgs {
  #     system = "x86_64-linux";
  #   };
  # };
in
with lib; {
  nixpkgs.overlays = [
    inputs.ataraxiasjel-nur.overlays.default
    inputs.ataraxiasjel-nur.overlays.grub2-argon2
    inputs.deploy-rs.overlay
    (final: prev:
      {
        attic = inputs.attic.packages.${system}.attic;
        attic-static = inputs.attic.packages.${system}.attic-static;
        cassowary-py = inputs.cassowary.packages.${system}.cassowary;
        devenv = inputs.devenv.packages.${system}.devenv;
        nix-alien = inputs.nix-alien.packages.${system}.nix-alien;
        nix-fast-build = inputs.nix-fast-build.packages.${system}.default;
        nix-index-update = inputs.nix-alien.packages.${system}.nix-index-update;
        prismlauncher = inputs.prismlauncher.packages.${system}.prismlauncher.override {
          jdks = [ pkgs.temurin-bin ];
        };
        xray = master.xray;
        youtube-to-mpv = prev.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        yt-dlp = master.yt-dlp;
        steam = prev.steam.override {
          extraPkgs = pkgs: with pkgs; [ mono libkrb5 keyutils ];
        };
        intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };

        neatvnc = prev.neatvnc.overrideAttrs (oa: {
          patches = [ ../patches/neatvnc.patch ] ++ oa.patches or [ ];
        });

        nix-direnv = inputs.nix-direnv.packages.${system}.default.override { nix = final.nix; };

        pass-secret-service = prev.pass-secret-service.overrideAttrs (_: {
          installCheckPhase = null;
          postInstall = ''
            mkdir -p $out/share/{dbus-1/services,xdg-desktop-portal/portals}
            cat > $out/share/dbus-1/services/org.freedesktop.secrets.service << EOF
            [D-BUS Service]
            Name=org.freedesktop.secrets
            Exec=/run/current-system/sw/bin/systemctl --user start pass-secret-service
            EOF
            cp $out/share/dbus-1/services/{org.freedesktop.secrets.service,org.freedesktop.impl.portal.Secret.service}
            cat > $out/share/xdg-desktop-portal/portals/pass-secret-service.portal << EOF
            [portal]
            DBusName=org.freedesktop.secrets
            Interfaces=org.freedesktop.impl.portal.Secrets
            UseIn=gnome
            EOF
          '';
        });

        narodmon-py = prev.writers.writePython3Bin "temp.py" {
          libraries = with prev.python3Packages; [ requests ];
        } ./packages/narodmon-py.nix;

        yandex-taxi-py = prev.writers.writePython3 "yandex-taxi.py" {
          libraries = with prev.python3Packages; [ requests ];
        } ./packages/yandex-taxi-py.nix;

        spotify-spotx = let
          spotx = with prev; stdenv.mkDerivation {
            pname = "spotx-bash";
            version = "unstable-2023-12-15";
            src = fetchFromGitHub {
              owner = "SpotX-Official";
              repo = "SpotX-Bash";
              rev = "a0823cb2f7495f9eaf0c94194abe6d2f0ff1b58c";
              hash = "sha256-qgG5m4ajlbq0G6D1Fx2x+yqxcz+OGN1zsfVDO2/koG4=";
            };
            dontBuild = true;
            nativeBuildInputs = [ makeBinaryWrapper ];
            installPhase = ''
              install -Dm 755 spotx.sh $out/bin/spotx
              sed -i 's/sxbLive=.\+/sxbLive=$buildVer/' $out/bin/spotx
              patchShebangs $out/bin/spotx
              wrapProgram $out/bin/spotx --prefix PATH : ${lib.makeBinPath [ perl unzip zip util-linux ]}
            '';
          };
        in prev.spotify.overrideAttrs (_oa: {
          postInstall = ''
            ${spotx}/bin/spotx -h -P "$out/share/spotify"
            rm -f "$out/share/spotify/Apps/xpui.bak" "$out/share/spotify/spotify.bak"
          '';
        });
        spotifywm = prev.spotifywm.override { spotify = final.spotify-spotx; };
      }
    )
  ];
}
