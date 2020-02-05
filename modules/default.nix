{ config, lib, ... }: {
  imports = [
    ./applications.nix
    ./devices.nix
    ./filesystems.nix
    ./hardware.nix
    ./network.nix
    ./packages.nix
    ./power.nix
    ./samba.nix
    ./secrets.nix
    ./services.nix
    ./themes.nix
    ./users.nix
    ./wireguard.nix
    ./xserver.nix

    ./applications/packages.nix

    # ./workspace/barrier.nix
    ./workspace/dunst.nix
    ./workspace/fonts.nix
    ./workspace/gtk.nix
    ./workspace/i3
    ./workspace/i3blocks
    ./workspace/kde
    ./workspace/light.nix
    ./workspace/locale.nix
    ./workspace/misc.nix
    ./workspace/mpv.nix
    ./workspace/rofi.nix
    ./workspace/xresources.nix
    ./workspace/zsh.nix
  ];
}
