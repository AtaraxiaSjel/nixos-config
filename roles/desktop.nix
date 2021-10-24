{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule

    applications-setup
    filesystems
    hardware
    mullvad
    samba
    services
    sound
    themes
    virtualisation
    xserver

    alacritty
    corectrl
    gamemode
    kitty
    mangohud
    mopidy
    mpv
    ncmpcpp
    packages
    rofi
    spotify
    steam
    # urxvt
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
    nix-index
    picom
    print-scan
  ];
}
