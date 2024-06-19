{ inputs, ... }: {
  imports = with inputs.self.customProfiles; [
    ./base.nix
    inputs.base16.hmModule

    hardware
    sound
    themes
    virtualisation

    corectrl
    element
    email
    firefox
    gamemode
    home-apps
    kitty
    mangohud
    mpv
    packages
    rofi
    spotify
    telegram
    steam
    vscode
    waydroid

    # aria2
    cursor
    direnv
    fonts
    gtk
    kde
    light
    mako
    nix-index
    pass-secret-service
    password-store
    print-scan
    proxy
    hyprland
    waybar
    wlogout
    xdg
    vpn

    mime-apps
    vscode-server
    catppuccin
  ];
}
