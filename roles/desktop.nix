{ inputs, ... }: {
  imports = with inputs.self.customProfiles; [
    ./base.nix
    inputs.base16.hmModule
    inputs.self.customProfiles.seadrive

    applications-setup
    hardware
    sound
    themes
    virtualisation

    alacritty
    corectrl
    element
    email
    firefox
    gamemode
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
