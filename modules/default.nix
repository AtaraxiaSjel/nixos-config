{ config, lib, ... }: {
  imports = [
    ./applications/packages.nix
    # ./applications/vivaldi
    ./workspace/i3blocks
    ./workspace/i3
    ./workspace/zsh.nix
    ./workspace/rofi.nix
    ./workspace/gtk.nix
    # ./workspace/compton.nix
    ./workspace/misc.nix
    ./workspace/dunst.nix
    ./workspace/mpv.nix
    ./workspace/kde
    ./workspace/locale.nix
    ./workspace/fonts.nix
    ./workspace/light.nix
    ./workspace/xresources.nix
    ./workspace/barrier.nix
    ./workspace/podman.nix
    ./workspace/direnv.nix
    ./themes.nix
    ./mullvad.nix
    ./applications.nix
    ./secrets.nix
    ./devices.nix
    ./packages.nix
    ./nix.nix
    ./users.nix
    ./hardware.nix
    ./services.nix
    ./power.nix
    ./xserver.nix
    ./network.nix
    ./wireguard.nix
    ./filesystems.nix
    ./samba.nix
  ];
}
