{ pkgs, config, lib, inputs, ... }:
let
  inherit (pkgs.hostPlatform) system;
  master = import inputs.nixpkgs-master {
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  };
  roundcube-plugins = import ./packages/roundcube-plugins/default.nix;
in
with lib; {
  nixpkgs.overlays = [
    inputs.nur.overlay
    roundcube-plugins
    (import ./packages/grub/default.nix)
    (final: prev:
      rec {
        inherit inputs;

        arkenfox-userjs = prev.callPackage ./packages/arkenfox-userjs.nix { arkenfox-repo = inputs.arkenfox-userjs; };
        a2ln = prev.callPackage ./packages/a2ln.nix { };
        bibata-cursors-tokyonight = prev.callPackage ./packages/bibata-cursors-tokyonight.nix { };
        ceserver = prev.callPackage ./packages/ceserver.nix { };
        microbin = prev.callPackage ./packages/microbin-pkg { };
        mpris-ctl = prev.callPackage ./packages/mpris-ctl.nix { };
        parsec = prev.callPackage ./packages/parsec.nix { };
        proton-ge = prev.callPackage ./packages/proton-ge { };
        protonhax = prev.callPackage ./packages/protonhax.nix { };
        reshade-shaders = prev.callPackage ./packages/reshade-shaders.nix { };
        rosepine-gtk-theme = prev.callPackage ./packages/rosepine-gtk-theme.nix { };
        rosepine-icon-theme = prev.callPackage ./packages/rosepine-icon-theme.nix { };
        tokyonight-gtk-theme = prev.callPackage ./packages/tokyonight-gtk-theme.nix { };
        tokyonight-icon-theme = prev.callPackage ./packages/tokyonight-icon-theme.nix { };
        youtube-to-mpv = prev.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        seadrive-fuse = prev.callPackage ./packages/seadrive-fuse.nix { };
        steam = master.steam.override {
          extraPkgs = pkgs: with pkgs; [ mono libkrb5 keyutils ];
        };
        waybar = inputs.hyprland.packages.${system}.waybar-hyprland;
        waydroid-script = prev.callPackage ./packages/waydroid-script.nix { };
        wine = prev.wineWowPackages.staging;
        prismlauncher = inputs.prismlauncher.packages.${system}.default;
        nix-alien = inputs.nix-alien.packages.${system}.nix-alien;
        nix-index-update = inputs.nix-alien.packages.${system}.nix-index-update;
        yt-dlp = master.yt-dlp;

        nix = inputs.nix.packages.${system}.default.overrideAttrs (oa: {
          doInstallCheck = false;
          patches = [ ./nix/doas.patch ] ++ oa.patches or [ ];
        });

        nix-direnv = inputs.nix-direnv.packages.${system}.default.override { pkgs = final; };
        # For nix-direnv
        nixFlakes = final.nix;

        cassowary-py = inputs.cassowary.packages.${system}.cassowary;

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

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
