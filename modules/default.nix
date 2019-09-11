{ ... }: {
  imports = [
    ./applications/packages.nix
    # ./applications/kate.nix
    # ./applications/emacs
    # ./applications/xst.nix
    # ./applications/trojita.nix
    # ./applications/firefox.nix
    # ./applications/okular.nix
    # ./applications/weechat.nix
    # ./applications/spectral.nix
    # ./workspace/i3blocks
    ./workspace/i3
    ./workspace/zsh.nix
    ./workspace/gtk.nix
    ./workspace/compton.nix
    ./workspace/misc.nix
    ./workspace/dunst.nix
    # ./workspace/kde
    # ./workspace/synergy.nix
    # ./workspace/ssh.nix
    ./workspace/locale.nix
    ./workspace/fonts.nix
    ./workspace/light.nix
    # ./workspace/autorandr.nix
    # ./workspace/gcalcli.nix
    # ./workspace/rclone.nix
    ./workspace/xresources.nix
    ./themes.nix
    ./applications.nix
    ./secrets.nix
    ./devices.nix
    # ./packages.nix
    ./nix.nix
    ./users.nix
    ./hardware.nix
    ./services.nix
    ./power.nix
    ./xserver.nix
    ./network.nix
    ./wireguard.nix
    ./filesystems.nix
  ];
}
