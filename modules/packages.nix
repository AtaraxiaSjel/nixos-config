{ pkgs, config, lib, ... }: {
  nixpkgs.overlays = [
    (self: old: rec {
      # nerdfonts = nur.balsoft.pkgs.roboto-mono-nerd;
      youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix {};
      xonar-fp = pkgs.writers.writeBashBin "xonar-fp" ''
        CURRENT_STATE=`amixer -c 0 sget "Front Panel" | egrep -o '\[o.+\]'`
        if [[ $CURRENT_STATE == '[on]' ]]; then
            amixer -c 0 sset "Front Panel" mute
        else
            amixer -c 0 sset "Front Panel" unmute
        fi
      '';
    })
    (self: super: {
      vscode-with-extensions = super.vscode-with-extensions.override {
        # When the extension is already available in the default extensions set.
        vscodeExtensions = with super.vscode-extensions; [
          bbenoist.Nix
          ms-python.python
        ];
      };
    })
  ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      i3lock-fancy = pkgs.callPackage ./applications/i3lock-fancy.nix {};
      git-with-libsecret = pkgs.git.override { withLibsecret = true; };
      mullvad-vpn = pkgs.mullvad-vpn.overrideAttrs (oldAttrs: rec {
        version = "2019.8";
        src = pkgs.fetchurl {
          url = "https://www.mullvad.net/media/app/MullvadVPN-${version}_amd64.deb";
          sha256 = "0cjc8j8pqgdhnax4mvwmvnxfcygjsp805hxalfaj8wa5adph96hz";
        };
      });
    };
  };
}