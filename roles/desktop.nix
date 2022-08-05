{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule

    xray

    applications-setup
    filesystems
    hardware
    mullvad
    samba
    services
    sound
    themes
    virtualisation

    alacritty
    corectrl
    firefox
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
    waydroid

    copyq
    cursor
    direnv
    fonts
    gtk
    i3status-rust
    kde
    light
    mako
    nix-index
    # picom
    print-scan
    proxy
    sway
    hyprland

    vscode-server
  ];
}
