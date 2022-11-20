{ pkgs, config, lib, inputs, ... }:
let
  inherit (pkgs) system;
  master = import inputs.nixpkgs-master ({
    config = config.nixpkgs.config;
    localSystem = { inherit system; };
  });
  roundcube-plugins = import ./packages/roundcube-plugins/default.nix;
in
with lib; {
  nixpkgs.overlays = [
    # inputs.nixpkgs-wayland.overlay
    inputs.nix-alien.overlay
    inputs.nur.overlay
    inputs.polymc.overlay
    # inputs.nixos-rocm.overlay
    roundcube-plugins
    (self: super:
      rec {
        inherit inputs;

        android-emulator = self.callPackage ./packages/android-emulator.nix { };
        arkenfox-userjs = pkgs.callPackage ./packages/arkenfox-userjs.nix { arkenfox-repo = inputs.arkenfox-userjs; };
        bibata-cursors-tokyonight = pkgs.callPackage ./packages/bibata-cursors-tokyonight.nix { };
        ceserver = pkgs.callPackage ./packages/ceserver.nix { };
        hyprpaper = pkgs.callPackage ./packages/hyprpaper.nix { src = inputs.hyprpaper; };
        kitti3 = pkgs.python3Packages.callPackage ./packages/kitti3.nix { };
        microbin = pkgs.callPackage ./packages/microbin-pkg { };
        mpris-ctl = pkgs.callPackage ./packages/mpris-ctl.nix { };
        parsec = pkgs.callPackage ./packages/parsec.nix { };
        reshade-shaders = pkgs.callPackage ./packages/reshade-shaders.nix { };
        rosepine-gtk-theme = pkgs.callPackage ./packages/rosepine-gtk-theme.nix { };
        rosepine-icon-theme = pkgs.callPackage ./packages/rosepine-icon-theme.nix { };
        seadrive-fuse = pkgs.callPackage ./packages/seadrive-fuse.nix { };
        tidal-dl = pkgs.callPackage ./packages/tidal-dl.nix { };
        tokyonight-gtk-theme = pkgs.callPackage ./packages/tokyonight-gtk-theme.nix { };
        tokyonight-icon-theme = pkgs.callPackage ./packages/tokyonight-icon-theme.nix { };
        vscode = master.vscode;
        vscode-fhs = master.vscode-fhs;
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        # xray-core = pkgs.callPackage ./packages/xray-core.nix { };
        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        vivaldi = master.vivaldi;
        # steam = stable.steam.override {
        #   extraPkgs = pkgs: with pkgs; [ libkrb5 keyutils ];
        # };
        waybar = inputs.nixpkgs-wayland.packages.${system}.waybar.overrideAttrs (old: {
          mesonFlags = old.mesonFlags ++ [
            "-Dexperimental=true"
          ];
        });
        waydroid-script = pkgs.callPackage ./packages/waydroid-script.nix { };
        wine = super.wineWowPackages.staging;
        qbittorrent = super.qbittorrent.overrideAttrs (old: rec {
          version = "enchanced-edition";
          src = inputs.qbittorrent-ee;
        });

        nix = inputs.nix.packages.${system}.default.overrideAttrs (oa: {
          doInstallCheck = false;
          patches = [ ./nix/nix.patch ] ++ oa.patches or [ ];
        });

        pass-secret-service = super.pass-secret-service.overrideAttrs (_: {
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
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
