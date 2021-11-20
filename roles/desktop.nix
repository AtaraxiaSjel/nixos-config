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
    himalaya
    kitty
    mangohud
    mpv
    # ncmpcpp
    packages
    piper
    rofi
    spotify
    steam
    syncthing
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
