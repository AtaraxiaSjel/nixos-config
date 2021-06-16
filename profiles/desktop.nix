{ inputs, ... }: {
  imports = with inputs.self.nixosModules; [
    ./base.nix
    inputs.base16.hmModule

    applications-setup
    filesystems
    hardware
    samba
    services
    sound
    themes
    virtualisation
    wireguard
    xserver

    alacritty
    kitty
    mpv
    packages
    rofi
    spotify
    urxvt
    vivaldi
    vscode

    cursor
    direnv
    dunst
    fonts
    gtk
    i3
    i3status-rust
    kde
    light
    picom
    print-scan
    xresources
  ];
}
