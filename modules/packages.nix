{ pkgs, config, lib, ... }: {
  nixpkgs.overlays = [
    (self: old:
      rec {
        # nerdfonts = nur.balsoft.pkgs.roboto-mono-nerd;
        youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix {};
      }
    )
  ];
}