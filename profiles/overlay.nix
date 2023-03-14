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
    # inputs.nixpkgs-wayland.overlay
    inputs.nix-alien.overlay
    inputs.nur.overlay
    roundcube-plugins
    (final: prev:
      rec {
        inherit inputs;

        android-emulator = final.callPackage ./packages/android-emulator.nix { };
        arkenfox-userjs = pkgs.callPackage ./packages/arkenfox-userjs.nix { arkenfox-repo = inputs.arkenfox-userjs; };
        a2ln = pkgs.callPackage ./packages/a2ln.nix { };
        bibata-cursors-tokyonight = pkgs.callPackage ./packages/bibata-cursors-tokyonight.nix { };
        ceserver = pkgs.callPackage ./packages/ceserver.nix { };
        hyprpaper = pkgs.callPackage ./packages/hyprpaper.nix { src = inputs.hyprpaper; };
        kitti3 = pkgs.python3Packages.callPackage ./packages/kitti3.nix { };
        microbin = pkgs.callPackage ./packages/microbin-pkg { };
        mpris-ctl = pkgs.callPackage ./packages/mpris-ctl.nix { };
        parsec = pkgs.callPackage ./packages/parsec.nix { };
        protonhax = pkgs.callPackage ./packages/protonhax.nix { };
        reshade-shaders = pkgs.callPackage ./packages/reshade-shaders.nix { };
        rosepine-gtk-theme = pkgs.callPackage ./packages/rosepine-gtk-theme.nix { };
        rosepine-icon-theme = pkgs.callPackage ./packages/rosepine-icon-theme.nix { };
        tidal-dl = pkgs.callPackage ./packages/tidal-dl.nix { };
        tokyonight-gtk-theme = pkgs.callPackage ./packages/tokyonight-gtk-theme.nix { };
        tokyonight-icon-theme = pkgs.callPackage ./packages/tokyonight-icon-theme.nix { };
        xonar-fp = pkgs.callPackage ./packages/xonar-fp.nix { };
        youtube-to-mpv = pkgs.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
        seadrive-fuse = pkgs.callPackage ./packages/seadrive-fuse.nix { };
        steam = master.steam.override {
          extraPkgs = pkgs: with pkgs; [ mono libkrb5 keyutils ];
        };
        waybar = inputs.nixpkgs-wayland.packages.${system}.waybar.overrideAttrs (old: {
          preBuildPhase = ''
            sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch workspace " + name_;\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
          '';
          mesonFlags = old.mesonFlags ++ [
            "-Dexperimental=true"
          ];
        });
        waydroid-script = pkgs.callPackage ./packages/waydroid-script.nix { };
        wine = prev.wineWowPackages.staging;
        qbittorrent = prev.qbittorrent.overrideAttrs (old: rec {
          version = "enchanced-edition";
          src = inputs.qbittorrent-ee;
        });
        prismlauncher = prev.prismlauncher.overrideAttrs (old: {
          version = "git-master";
          src = inputs.prismlauncher;
          buildInputs = old.buildInputs ++ [ prev.cmark ];
        });

        nix = inputs.nix.packages.${system}.default.overrideAttrs (oa: {
          doInstallCheck = false;
          patches = [ ./nix/nix.patch ./nix/doas.patch ] ++ oa.patches or [ ];
        });

        nix-direnv = inputs.nix-direnv.packages.${system}.default.override { pkgs = final; };
        # For nix-direnv
        nixFlakes = final.nix;

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

        grub2 = prev.callPackage ./packages/grub { };

        narodmon-py = prev.writers.writePython3Bin "temp.py" {
          libraries = with prev.python3Packages; [ requests ];
        } ./packages/narodmon-py.nix;
      }
    )
  ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
