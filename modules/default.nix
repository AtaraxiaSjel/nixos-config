builtins.listToAttrs (builtins.map (path: {
  name = builtins.head (let
    b = builtins.baseNameOf path;
    m = builtins.match "(.*)\\.nix" b;
  in if isNull m then [ b ] else m);
  value = import path;
}) [
  ./applications/alacritty.nix
  ./applications/kitty.nix
  ./applications/mpv.nix
  ./applications/packages.nix
  ./applications/rofi.nix
  ./applications/spotify
  ./applications/urxvt.nix
  ./applications/vscode.nix

  # ./sound/pulseeffects

  # ./workspace/barrier.nix
  ./workspace/cursor.nix
  ./workspace/dunst.nix
  ./workspace/fonts.nix
  ./workspace/git.nix
  ./workspace/gpg.nix
  ./workspace/gtk.nix
  ./workspace/i3
  ./workspace/i3status-rust
  ./workspace/kde
  ./workspace/light.nix
  ./workspace/locale.nix
  ./workspace/misc.nix
  ./workspace/picom.nix
  ./workspace/ssh.nix
  ./workspace/xresources.nix
  ./workspace/zsh.nix

  ./applications.nix
  ./boot.nix
  ./devices.nix
  ./filesystems.nix
  ./hardware.nix
  ./network.nix
  ./nix.nix
  ./overlay.nix
  ./power.nix
  ./samba.nix
  ./secrets.nix
  ./security.nix
  ./services.nix
  ./sound
  ./themes.nix
  ./virtualisation.nix
  ./wireguard.nix
  ./xserver.nix
])
