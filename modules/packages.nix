{ pkgs, config, lib, ... }: {
  nixpkgs.overlays = [
    (self: old:
      rec {
        # nerdfonts = nur.balsoft.pkgs.roboto-mono-nerd;
        youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix {};
      }
    )
  ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      i3lock-fancy = pkgs.callPackage ./applications/i3lock-fancy.nix {};
      # mullvad-vpn = pkgs.mullvad-vpn.overrideAttrs (oldAttrs: rec {
      #   version = "2019.8";
      #   src = pkgs.fetchurl {
      #     url = "https://www.mullvad.net/media/app/MullvadVPN-${version}_amd64.deb";
      #     sha256 = "0cjc8j8pqgdhnax4mvwmvnxfcygjsp805hxalfaj8wa5adph96hz";
      #   };
      # });
    };
  };
}