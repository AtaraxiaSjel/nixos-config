{ config, lib, ... }: {
  imports = [
    ./applications/packages.nix
    ./applications/rofi.nix
    # ./applications/vivaldi
    ./workspace/i3blocks
    ./workspace/i3
    ./workspace/zsh.nix
    ./workspace/gtk.nix
    # ./workspace/compton.nix
    ./workspace/misc.nix
    ./workspace/dunst.nix
    ./workspace/cursor.nix
    ./workspace/mpv.nix
    ./workspace/kde
    # ./workspace/ssh.nix
    ./workspace/locale.nix
    ./workspace/fonts.nix
    ./workspace/light.nix
    # ./workspace/autorandr.nix
    # ./workspace/gcalcli.nix
    # ./workspace/rclone.nix
    ./workspace/xresources.nix
    ./workspace/barrier.nix
    ./barrier-conf.nix
    ./themes.nix
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
