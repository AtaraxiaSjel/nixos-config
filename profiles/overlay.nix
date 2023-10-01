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
  nur = import inputs.nur {
    nurpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
    };
  };
in
with lib; {
  nixpkgs.overlays = [
    nur.repos.ataraxiasjel.overlays.default
    nur.repos.ataraxiasjel.overlays.grub2-argon2
    inputs.deploy-rs.overlay
    inputs.hyprland.overlays.default
    (final: prev:
      {
        attic = inputs.attic.packages.${system}.attic;
        attic-static = inputs.attic.packages.${system}.attic-static;
        cassowary-py = inputs.cassowary.packages.${system}.cassowary;
        devenv = inputs.devenv.packages.${system}.devenv;
        nix-alien = inputs.nix-alien.packages.${system}.nix-alien;
        nix-index-update = inputs.nix-alien.packages.${system}.nix-index-update;
        prismlauncher = inputs.prismlauncher.packages.${system}.default;
        ripgrep-all = stable.ripgrep-all;
        spotify = master.spotify;
        wine = prev.wineWowPackages.staging;
        xray = master.xray;
        youtube-to-mpv = prev.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        yt-dlp = master.yt-dlp;
        steam = master.steam.override {
          extraPkgs = pkgs: with pkgs; [ mono libkrb5 keyutils ];
        };

        neatvnc = prev.neatvnc.overrideAttrs (oa: {
          patches = [ ../patches/neatvnc.patch ] ++ oa.patches or [ ];
        });

        nix = inputs.nix.packages.${system}.default.overrideAttrs (oa: {
          doInstallCheck = false;
          patches = [ ./nix/doas.patch ] ++ oa.patches or [ ];
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

		# can't build with nix 2.17
        nixos-option = stable.nixos-option;
        nil = stable.nil;
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
    # vscode-server requires nodejs_16
    # permittedInsecurePackages = [
    #   "nodejs-16.20.1"
    # ];
  };
}
