{ inputs, ... }: {
  imports = with inputs.self.customProfiles; [
    ./base.nix
    inputs.base16.hmModule

    applications-setup
    hardware
    sound
    themes
    virtualisation

    corectrl
    element
    email
    firefox
    gamemode
    kitty
    mangohud
    mpv
    packages
    rofi
    spotify
    steam
    vscode
    waydroid
    zathura

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
    xdg
    vpn

    vscode-server
  ];
}
