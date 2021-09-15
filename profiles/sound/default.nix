{ config, lib, pkgs, ... }: {
  # sound.enable = true;

  imports = [
    ./pipewire.nix
    ./easyeffects
    # ./mopidy.nix
  ];


}