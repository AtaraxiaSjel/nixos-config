{ inputs, ... }: {
  imports = with inputs.self.customModules; with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule

    inputs.self.customModules.seadrive
    inputs.self.nixosProfiles.seadrive
    xray

    applications-setup
    hardware
    services
    sound
    themes
    virtualisation
    vpn

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
    print-scan
    proxy
    hyprland
    waybar
    xdg

    vscode-server
  ];
}
