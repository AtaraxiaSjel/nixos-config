{ config, lib, pkgs, ... }: {
  sound.enable = true;

  imports = [
    ./pulseaudio.nix
    ./mopidy.nix
  ];


}