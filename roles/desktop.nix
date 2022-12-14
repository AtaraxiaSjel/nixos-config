{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule

    seadrive
    xray

    applications-setup
    hardware
    mullvad
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
    rofi
    spotify
    steam
    tor-browser
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
