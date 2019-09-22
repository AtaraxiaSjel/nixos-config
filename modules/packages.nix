{ pkgs, config, lib, ... }: {
  nixpkgs.overlays = [
    (self: old:
      rec {
        # nerdfonts = nur.balsoft.pkgs.roboto-mono-nerd;
        youtube-to-mpv = pkgs.callPackage ./applications/youtube-to-mpv.nix {};
        i3lock-fancy-ffmpeg = pkgs.callPackage ./applications/i3lock-fancy-ffmpeg.nix {};
      }
    )
  ];
}