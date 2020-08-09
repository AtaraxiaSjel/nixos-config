device:
{ config, lib, ... }: {
  imports = [
    ./applications/alacritty.nix
    ./applications/packages.nix
    ./applications/rofi.nix
    ./applications/vscode.nix

    # ./workspace/barrier.nix
    ./workspace/dunst.nix
    ./workspace/fonts.nix
    ./workspace/gtk.nix
    ./workspace/i3
    ./workspace/i3status-rust
    ./workspace/kde
    ./workspace/light.nix
    ./workspace/locale.nix
    ./workspace/misc.nix
    ./workspace/mpv.nix
    ./workspace/pulseeffects
    ./workspace/qbittorrent
    # ./workspace/spotifyd.nix
    ./workspace/ssh.nix
    ./workspace/xresources.nix
    ./workspace/zsh.nix

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
    ./sound
    ./themes.nix
    ./users.nix
    ./wireguard.nix
    ./xserver.nix
  ];
}
