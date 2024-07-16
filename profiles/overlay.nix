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
in
with lib; {
  nixpkgs.overlays = [
    inputs.ataraxiasjel-nur.overlays.default
    inputs.ataraxiasjel-nur.overlays.grub2-unstable-argon2
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
        open-webui = master.open-webui;
        prismlauncher = inputs.prismlauncher.packages.${system}.prismlauncher.override {
          jdks = [ pkgs.temurin-bin ];
        };
        xray = master.xray;
        youtube-to-mpv = prev.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        yt-archivist = prev.callPackage ./packages/yt-archivist { };
        yt-dlp = master.yt-dlp;
        steam = prev.steam.override {
          extraPkgs = pkgs: with pkgs; [ mono libkrb5 keyutils ];
        };
        wine = prev.wineWow64Packages.stagingFull;
        intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };

        modprobed-db = prev.modprobed-db.overrideAttrs (oa: {
          postPatch = (oa.postPatch or "") + ''
            substituteInPlace ./common/modprobed-db.in \
              --replace-fail "/modprobed-db.conf" "/modprobed-db/modprobed-db.conf"
            substituteInPlace ./common/modprobed-db.skel \
              --replace-fail "/.config" "/.config/modprobed-db"
          '';
        });

        neatvnc = prev.neatvnc.overrideAttrs (oa: {
          patches = [ ../patches/neatvnc.patch ] ++ oa.patches or [ ];
        });

        nix-direnv = inputs.nix-direnv.packages.${system}.default.override { nix = final.lix; };

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
      }
    )
  ];
}
