{ inputs, ... }: {
  imports = with inputs.self.nixosModules; [
    ./base.nix
    inputs.base16.hmModule

    applications
    filesystems
    hardware
    power
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
    vscode

    cursor
    dunst
    fonts
    gtk
    i3
    i3status-rust
    kde
    light
    picom
    pulseeffects
    xresources
  ];
}
