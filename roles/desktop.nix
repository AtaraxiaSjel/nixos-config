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
    google-drive
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
    # vivaldi
    vscode
    waydroid

    copyq
    cursor
    direnv
    fonts
    gtk
    kde
    light
    mako
    nix-index
    print-scan
    proxy
    hyprland
    waybar
    xdg

    vscode-server
  ];
}
