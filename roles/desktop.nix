{ inputs, ... }: {
  imports = with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule
    inputs.self.nixosProfiles.seadrive

    applications-setup
    hardware
    sound
    themes
    virtualisation
    vpn

    alacritty
    corectrl
    element
    firefox
    gamemode
    himalaya
    kitty
    mangohud
    mpv
    # ncmpcpp
    packages
    rclone
    rofi
    spotify
    steam
    tor-browser
    vscode
    waydroid
    zathura

    aria2
    copyq
    cursor
    direnv
    fonts
    gtk
    kde
    light
    mako
    nix-index
    pass-secret-service
    print-scan
    proxy
    hyprland
    waybar
    xdg

    vscode-server
  ];
}
